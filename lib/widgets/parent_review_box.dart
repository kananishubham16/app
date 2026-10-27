import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:learning_setu/models/user_model.dart';
import 'package:learning_setu/providers/auth_provider.dart';
import 'package:learning_setu/providers/parent_review_provider.dart';

/// Interactive review box placed below a student's marks display.
///
/// Rules:
/// - Parents can write, view, and update their subject-specific review notes.
/// - Teachers can ONLY view and acknowledge reviews if they teach that specific subject
///   (i.e., user.role == UserRole.teacher && user.subjectIds.contains(subjectId)).
/// - Teachers of other subjects, Principals, and BRC observers cannot view private parent reviews.
class ParentReviewBox extends StatefulWidget {
  final String studentId;
  final String subjectId;
  final String subjectName;
  final bool compact;

  const ParentReviewBox({
    super.key,
    required this.studentId,
    required this.subjectId,
    required this.subjectName,
    this.compact = false,
  });

  @override
  State<ParentReviewBox> createState() => _ParentReviewBoxState();
}

class _ParentReviewBoxState extends State<ParentReviewBox> {
  bool _isEditing = false;
  bool _isAnswering = false;
  late final TextEditingController _textController;
  late final TextEditingController _responseController;
  final _formKey = GlobalKey<FormState>();
  final _responseFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _responseController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider?>(context);
    final reviewProv = Provider.of<ParentReviewProvider?>(context);
    final user = authProv?.currentUser;
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    if (reviewProv == null) {
      return const SizedBox.shrink();
    }

    final review = reviewProv.getReview(widget.studentId, widget.subjectId);

    // ==========================================
    // 1. PARENT VIEW
    // ==========================================
    if (user?.role == UserRole.parent) {
      return _buildParentView(context, review, isGu, reviewProv, user);
    }

    // ==========================================
    // 2. TEACHER VIEW (Strictly gated to assigned subject)
    // ==========================================
    final isAssignedSubjectTeacher = user?.role == UserRole.teacher &&
        (user?.subjectIds?.contains(widget.subjectId) ?? false);

    if (isAssignedSubjectTeacher) {
      return _buildTeacherView(context, review, isGu, reviewProv, user);
    }

    // ==========================================
    // 3. OTHER USERS (Principals, BRC, Teachers of other subjects)
    // ==========================================
    // Confidential: return SizedBox.shrink() to preserve privacy
    return const SizedBox.shrink();
  }

  // ------------------------------------------
  // Parent View Builder
  // ------------------------------------------
  Widget _buildParentView(
    BuildContext context,
    dynamic review,
    bool isGu,
    ParentReviewProvider reviewProv,
    UserModel? user,
  ) {
    final theme = Theme.of(context);
    final hasExistingReview = review != null && review.reviewText.isNotEmpty;

    if (hasExistingReview && !_isEditing) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: theme.colorScheme.primary.withOpacity(0.35),
            width: 1.2,
          ),
        ),
        color: theme.colorScheme.primaryContainer.withOpacity(0.18),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isGu
                          ? '${widget.subjectName} શિક્ષક માટે તમારો પ્રતિભાવ'
                          : 'Your Note to ${widget.subjectName} Teacher',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    tooltip: isGu ? 'ફેરફાર કરો' : 'Edit Note',
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                        _textController.text = review.reviewText;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Review text
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  '“${review.reviewText}”',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ),
              // Verified Teacher Response Card
              if (review.teacherResponse != null && review.teacherResponse!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.green.shade300,
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              isGu
                                  ? '${widget.subjectName} શિક્ષકનો ઉત્તર (${review.respondedBy ?? "શિક્ષક"})'
                                  : 'Teacher Response (${review.respondedBy ?? "${widget.subjectName} Teacher"})',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ),
                          if (review.respondedAt != null)
                            Text(
                              DateFormat('dd MMM').format(review.respondedAt!),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green.shade800,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        review.teacherResponse!,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
              // Footer: Date and Acknowledgement status
              LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        // Confidentiality label
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                size: 13,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  isGu
                                      ? 'ફક્ત ${widget.subjectName} શિક્ષક જ જોઈ શકે છે'
                                      : 'Only ${widget.subjectName} teacher can see this',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Acknowledgement tag
                        if (review.isAcknowledged)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 13,
                                  color: Colors.green.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isGu
                                      ? 'શિક્ષક દ્વારા વાંચેલ'
                                      : 'Read by ${review.acknowledgedBy ?? "Teacher"}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Answered tag
                        if (review.teacherResponse != null && review.teacherResponse!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.teal.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.mark_chat_read_rounded,
                                  size: 13,
                                  color: Colors.teal.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isGu
                                      ? 'ઉત્તર મળેલ છે'
                                      : 'Response Received',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    // Edit or Write mode
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.8),
        ),
      ),
      color: theme.colorScheme.surfaceVariant.withOpacity(0.35),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isGu
                          ? '${widget.subjectName} શિક્ષક માટે વાલી પ્રતિભાવ બોક્સ'
                          : 'Parent Review Box for ${widget.subjectName} Teacher',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.lock_rounded,
                    size: 12,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      isGu
                          ? 'આ નોંધ ફક્ત ${widget.subjectName} ના વિષય શિક્ષક જ જોઈ શકશે.'
                          : 'Private: Seen exclusively by the assigned ${widget.subjectName} teacher.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _textController,
                maxLines: 3,
                minLines: 2,
                decoration: InputDecoration(
                  hintText: isGu
                      ? 'ગુણ, હોમવર્ક અથવા મુશ્કેલીઓ અંગે શિક્ષકને પ્રશ્ન કે નોંધ લખો...'
                      : 'Write your notes, observations, or questions about marks & practice...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return isGu
                        ? 'કૃપા કરીને પ્રતિભાવ લખો.'
                        : 'Please enter your note or review.';
                  }
                  return null;
                },
              ),
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_isEditing)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                          });
                        },
                        child: Text(isGu ? 'રદ કરો' : 'Cancel'),
                      ),
                    FilledButton.icon(
                      icon: const Icon(Icons.send_rounded, size: 15),
                      label: Text(
                        isGu
                            ? (_isEditing ? 'અપડેટ કરો' : 'પ્રતિભાવ મોકલો')
                            : (_isEditing ? 'Update Review' : 'Submit Review'),
                      ),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          final text = _textController.text.trim();
                          final parentName = user?.name ??
                              (isGu ? 'વાલી' : 'Parent');

                          await reviewProv.submitOrUpdateReview(
                            studentId: widget.studentId,
                            subjectId: widget.subjectId,
                            parentName: parentName,
                            reviewText: text,
                          );

                          if (context.mounted) {
                            setState(() {
                              _isEditing = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isGu
                                      ? 'પ્રતિભાવ સફળતાપૂર્વક મોકલાયો! ફક્ત ${widget.subjectName} શિક્ષક જ જોઈ શકશે.'
                                      : 'Review sent! Only ${widget.subjectName} teacher can view this.',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------
  // Teacher View Builder (Strictly Subject Teacher)
  // ------------------------------------------
  Widget _buildTeacherView(
    BuildContext context,
    dynamic review,
    bool isGu,
    ParentReviewProvider reviewProv,
    UserModel? user,
  ) {
    final theme = Theme.of(context);
    final hasReview = review != null && review.reviewText.isNotEmpty;

    if (!hasReview) {
      if (widget.compact) {
        return const SizedBox.shrink();
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.mark_chat_read_outlined,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isGu
                    ? 'આ વિષય માટે વાલી તરફથી કોઈ પ્રતિભાવ મળેલ નથી.'
                    : 'No parent review submitted for ${widget.subjectName} yet.',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final dateFormat = DateFormat('dd MMM yyyy');
    final formattedDate = dateFormat.format(review.createdAt);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: Colors.purple.shade300,
          width: 1.2,
        ),
      ),
      color: Colors.purple.shade50.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teacher Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.family_restroom_rounded,
                    size: 18,
                    color: Colors.purple.shade800,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGu
                            ? 'વાલીનો પ્રતિભાવ (ફક્ત તમારા વિષય માટે)'
                            : "Parent's Review (Confidential for Your Subject)",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${review.parentName} • $formattedDate',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.purple.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_rounded,
                        size: 11,
                        color: Colors.purple.shade900,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        isGu ? 'શિક્ષક માટે' : 'Teacher Only',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Review body
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.purple.shade100),
              ),
              child: Text(
                '“${review.reviewText}”',
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Existing Teacher Response (if any and not editing)
            if (review.teacherResponse != null && review.teacherResponse!.isNotEmpty && !_isAnswering) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade300, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            isGu
                                ? 'તમારો ઉત્તર (વાલીને દૃશ્યમાન):'
                                : 'Your Response (Visible to Parent):',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _isAnswering = true;
                              _responseController.text = review.teacherResponse ?? '';
                            });
                          },
                          icon: const Icon(Icons.edit_outlined, size: 14),
                          label: Text(
                            isGu ? 'સુધારો' : 'Edit',
                            style: const TextStyle(fontSize: 11),
                          ),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      review.teacherResponse!,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Interactive Answer Form (when teacher clicks Answer / Edit)
            if (_isAnswering) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.purple.shade300, width: 1.5),
                ),
                child: Form(
                  key: _responseFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.reply_rounded, size: 16, color: Colors.purple.shade800),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              isGu ? 'વાલીને ઉત્તર / માર્ગદર્શન આપો:' : 'Answer / Guide the Parent:',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Quick reply chips
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          ActionChip(
                            visualDensity: VisualDensity.compact,
                            avatar: const Icon(Icons.flash_on, size: 13, color: Colors.orange),
                            label: Text(
                              isGu ? 'રોજ 10 મિનિટ મહાવરો' : '10 min daily practice',
                              style: const TextStyle(fontSize: 11),
                            ),
                            onPressed: () {
                              _responseController.text = isGu
                                  ? 'વાલીશ્રી, ઘરમાં રોજ 10-15 મિનિટ નિયમિત પુનરાવર્તન કરાવો. વર્ગખંડમાં અમે ખાસ ધ્યાન રાખીશું.'
                                  : 'Dear Parent, practicing for 10-15 minutes at home daily will help reinforce this. We will give extra attention in class.';
                            },
                          ),
                          ActionChip(
                            visualDensity: VisualDensity.compact,
                            avatar: const Icon(Icons.thumb_up_alt_outlined, size: 13, color: Colors.green),
                            label: Text(
                              isGu ? 'વર્ગમાં સારી પ્રગતિ' : 'Good class progress',
                              style: const TextStyle(fontSize: 11),
                            ),
                            onPressed: () {
                              _responseController.text = isGu
                                  ? 'વિદ્યાર્થી વર્ગખંડમાં સારો રસ દાખવી રહ્યો છે અને પ્રગતિ ઉત્સાહજનક છે.'
                                  : 'The student is showing great enthusiasm and steady progress during classroom activities.';
                            },
                          ),
                          ActionChip(
                            visualDensity: VisualDensity.compact,
                            avatar: const Icon(Icons.auto_stories, size: 13, color: Colors.blue),
                            label: Text(
                              isGu ? 'ઉપચારાત્મક સત્ર' : 'Remedial session',
                              style: const TextStyle(fontSize: 11),
                            ),
                            onPressed: () {
                              _responseController.text = isGu
                                  ? 'આ વિષયના મુશ્કેલ મુદ્દાઓ માટે અમે ઉપચારાત્મક (Remedial) વર્ગમાં ખાસ માર્ગદર્શન આપી રહ્યા છીએ.'
                                  : 'We have enrolled the student in focused remedial learning sessions to strengthen basic fundamentals.';
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _responseController,
                        maxLines: 3,
                        minLines: 2,
                        decoration: InputDecoration(
                          hintText: isGu
                              ? 'વાલીના પ્રશ્ન અથવા સમીક્ષાનો ઉત્તર લખો...'
                              : 'Write your verified guidance or response to the parent...',
                          hintStyle: TextStyle(
                            fontSize: 12.5,
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.purple.shade200),
                          ),
                          contentPadding: const EdgeInsets.all(10),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return isGu ? 'કૃપા કરીને ઉત્તર લખો' : 'Please write your response';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isAnswering = false;
                              });
                            },
                            child: Text(isGu ? 'રદ કરો' : 'Cancel'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            icon: const Icon(Icons.send_rounded, size: 14),
                            label: Text(isGu ? 'ઉત્તર મોકલો' : 'Submit Answer'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.purple.shade700,
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              if (_responseFormKey.currentState?.validate() ?? false) {
                                final text = _responseController.text.trim();
                                final teacherName = user?.name ?? 'Subject Teacher';
                                await reviewProv.submitTeacherResponse(
                                  reviewId: review.id,
                                  responseText: text,
                                  teacherName: teacherName,
                                );
                                if (context.mounted) {
                                  setState(() {
                                    _isAnswering = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isGu
                                            ? 'વાલીને ઉત્તર સફળતાપૂર્વક મોકલાયો!'
                                            : 'Response successfully sent to parent!',
                                      ),
                                      backgroundColor: Colors.green.shade800,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            // Footer: Teacher Acknowledge Button & Answer Button
            LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                        child: Text(
                          isGu
                              ? 'વિદ્યાર્થીના ગુણ અને પ્રગતિ પર વાલીનો પ્રતિભાવ'
                              : 'Feedback on student performance & marks',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              final teacherName = user?.name ?? 'Teacher';
                              reviewProv.toggleAcknowledge(review.id, teacherName);
                            },
                            icon: Icon(
                              review.isAcknowledged
                                  ? Icons.check_circle_rounded
                                  : Icons.check_circle_outline_rounded,
                              size: 15,
                              color: review.isAcknowledged
                                  ? Colors.green.shade700
                                  : theme.colorScheme.primary,
                            ),
                            label: Text(
                              review.isAcknowledged
                                  ? (isGu ? 'સ્વીકારેલ છે' : 'Acknowledged')
                                  : (isGu ? 'વાંચ્યું / સ્વીકારો' : 'Acknowledge'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: review.isAcknowledged
                                    ? Colors.green.shade800
                                    : theme.colorScheme.primary,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              backgroundColor: review.isAcknowledged
                                  ? Colors.green.shade50
                                  : Colors.transparent,
                              side: BorderSide(
                                color: review.isAcknowledged
                                    ? Colors.green.shade300
                                    : theme.colorScheme.primary.withOpacity(0.5),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          if (!_isAnswering)
                            FilledButton.tonalIcon(
                              onPressed: () {
                                setState(() {
                                  _isAnswering = true;
                                  _responseController.text = review.teacherResponse ?? '';
                                });
                              },
                              icon: Icon(
                                review.teacherResponse != null && review.teacherResponse!.isNotEmpty
                                    ? Icons.edit_note_rounded
                                    : Icons.reply_rounded,
                                size: 15,
                              ),
                              label: Text(
                                review.teacherResponse != null && review.teacherResponse!.isNotEmpty
                                    ? (isGu ? 'ઉત્તરમાં સુધારો' : 'Edit Answer')
                                    : (isGu ? 'વાલીને ઉત્તર આપો' : 'Answer Parent'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
