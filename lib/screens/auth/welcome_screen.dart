import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learning_setu/models/user_model.dart';
import 'package:learning_setu/providers/locale_provider.dart';
import 'package:learning_setu/screens/auth/login_screen.dart';

/// WelcomeScreen provides the cloned web home page for EduTrack.
/// Faithfully reproduces all sections from web/index.html:
/// 1. Site Header (Brand + Prominent Language Selector + Portal Tag)
/// 2. Landing Hero Banner (Multi-stakeholder Badge + Title + Subtitle)
/// 3. Role Selection Section (4 Role Cards Grid with selectable checkmark & features)
/// 4. Current Selection Action Bar (Selected Role + Continue to Login button)
/// 5. Standardized Academic Performance Color System (Green/Yellow/Red Cards)
/// 6. Site Footer (Branding + Gujarat Primary Schools credit)
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  UserRole _selectedRole = UserRole.teacher;

  @override
  Widget build(BuildContext context) {
    final localeProv = context.watch<LocaleProvider>();
    final langCode = localeProv.locale.languageCode; // 'en', 'gu', or 'hi'

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Site Header
            _buildSiteHeader(context, langCode),

            // Main scrollable content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1140),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 2. Hero Banner
                          _buildHeroBanner(langCode),
                          const SizedBox(height: 24),

                          // 3. Role Selection Header
                          _buildRoleSectionHeader(langCode),
                          const SizedBox(height: 16),

                          // 4 Role Cards
                          _buildRoleCards(context, langCode),
                          const SizedBox(height: 18),

                          // 4. Continue Action Bar
                          _buildContinueActionBar(context, langCode),
                          const SizedBox(height: 32),

                          // 5. Standardized Performance Color System
                          _buildPerformanceColorSystem(langCode),
                          const SizedBox(height: 28),

                          // 6. Site Footer
                          _buildSiteFooter(langCode),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 1. SITE HEADER
  // ==========================================
  Widget _buildSiteHeader(BuildContext context, String lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Dark Primary Navy from web style.css
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              // Brand Logo & Title Group
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          lang == 'gu' ? 'એડ્યુટ્રેક' : (lang == 'hi' ? 'एडुट्रैक' : 'EduTrack'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          lang == 'gu'
                              ? 'સ્માર્ટ પરફોર્મન્સ મોનિટરિંગ'
                              : (lang == 'hi'
                                  ? 'स्मार्ट परफॉर्मेंस मॉनिटरिंग'
                                  : 'Smart Performance Monitoring'),
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Header Right: Prominent Language Selector + Academic Portal Badge
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Prominent Language Selector Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.language_rounded,
                          color: Color(0xFF14B8A6),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: (lang == 'gu' || lang == 'hi') ? lang : 'en',
                            dropdownColor: const Color(0xFF1E293B),
                            isDense: true,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xFF94A3B8),
                              size: 18,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'en',
                                child: Text(
                                  'English',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'gu',
                                child: Text(
                                  'ગુજરાતી',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'hi',
                                child: Text(
                                  'हिन्दी',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                context.read<LocaleProvider>().setLocale(Locale(val));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Primary & Middle Academic Portal Tag
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withOpacity(0.18),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.account_balance_outlined,
                            color: Color(0xFF2DD4BF),
                            size: 13,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            lang == 'gu'
                                ? 'પ્રાથમિક અને માધ્યમિક પોર્ટલ'
                                : (lang == 'hi'
                                    ? 'प्राथमिक एवं माध्यमिक पोर्टल'
                                    : 'Primary & Middle Academic Portal'),
                            style: const TextStyle(
                              color: Color(0xFF2DD4BF),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 2. HERO BANNER
  // ==========================================
  Widget _buildHeroBanner(String lang) {
    final badgeText = lang == 'gu'
        ? 'શૈક્ષણિક વિશ્લેષણ અને પ્રગતિ મૂલ્યાંકન પ્લેટફોર્મ'
        : (lang == 'hi'
            ? 'बहु-हितधारक शैक्षणिक विश्लेषण मंच'
            : 'Multi-Stakeholder Educational Intelligence Platform');

    final heading = lang == 'gu' ? 'એડ્યુટ્રેક' : (lang == 'hi' ? 'एडुट्रैक' : 'EduTrack');

    final subtitle = lang == 'gu'
        ? 'વિદ્યાર્થીઓની અધ્યયન ખામીઓની ઓળખ કરો, વર્ગખંડના પરિણામોનું નિરીક્ષણ કરો, સોંપેલ વર્ગોની સમીક્ષા કરો અને શિક્ષકો તથા વાલીઓ વચ્ચે પારદર્શક સંવાદ સાધો.'
        : (lang == 'hi'
            ? 'विद्यार्थियों के अध्ययन अंतराल की पहचान करें, कक्षा परिणामों की निगरानी करें, आवंटित ब्लॉकों की समीक्षा करें और शिक्षकों एवं अभिभावकों के बीच पारदर्शी संवाद स्थापित करें।'
            : 'Identify student learning gaps, monitor classroom outcomes, evaluate assigned school blocks, and foster transparent, joyful communication between teachers and parents.');

    return Column(
      children: [
        // Pill Badge
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFF0D9488),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  badgeText,
                  style: const TextStyle(
                    color: Color(0xFF0D9488),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Hero Heading
        Text(
          heading,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 3. ROLE SECTION HEADER
  // ==========================================
  Widget _buildRoleSectionHeader(String lang) {
    final title = lang == 'gu'
        ? 'આગળ વધવા માટે તમારું પોર્ટલ પસંદ કરો'
        : (lang == 'hi'
            ? 'आगे बढ़ने के लिए अपना पोर्टल चुनें'
            : 'Select Your Portal to Continue');

    final sub = lang == 'gu'
        ? 'કસ્ટમાઇઝ્ડ ડેશબોર્ડ, વિદ્યાર્થી એનાલિટિક્સ અને રિપોર્ટિંગ ટૂલ્સ મેળવવા માટે નીચે તમારી ભૂમિકા પસંદ કરો.'
        : (lang == 'hi'
            ? 'अनुकूलित डैशबोर्ड, छात्र विश्लेषण और रिपोर्टिंग टूल तक पहुँचने के लिए नीचे अपनी भूमिका चुनें।'
            : 'Choose your role below to access customized dashboards, student analytics, and reporting tools.');

    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          sub,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 4 ROLE CARDS
  // ==========================================
  Widget _buildRoleCards(BuildContext context, String lang) {
    final cards = [
      _RoleData(
        role: UserRole.teacher,
        title: lang == 'gu'
            ? 'શિક્ષકો (Teachers)'
            : (lang == 'hi' ? 'शिक्षक (Teachers)' : 'Teachers'),
        desc: lang == 'gu'
            ? 'વિષયવાર પ્રદર્શન મૂલ્યાંકન, ચોક્કસ મુદ્દાવાર શક્તિઓ અને ખામીઓનું નિદાન અને લાઈવ ગુણ એન્ટ્રી.'
            : (lang == 'hi'
                ? 'विषय-विशिष्ट दक्षता मूल्यांकन, विषयवार क्षमता एवं कमजोरी का निदान और अंक प्रविष्टि।'
                : 'Subject-specific mastery evaluation, granular topic strength and weakness diagnosis, and live mark entry.'),
        icon: Icons.co_present_rounded,
        color: const Color(0xFF0D9488), // Teal
        features: [
          lang == 'gu' ? '૫ વિષયો અને મુદ્દાવાર વિશ્લેષણ' : (lang == 'hi' ? '5 विषय एवं बिंदुवार विश्लेषण' : '5 Subjects & Topic breakdown'),
          lang == 'gu' ? 'ગુણ એન્ટ્રી અને નિદાન નોંધણી' : (lang == 'hi' ? 'अंक प्रविष्टि एवं निदान टिप्पणी' : 'Mark entry & diagnostic remarks'),
          lang == 'gu' ? 'રૂપરેખાંકિત પ્રદર્શન ચેતવણીઓ' : (lang == 'hi' ? 'कॉन्फ़िगर करने योग्य प्रदर्शन अलर्ट' : 'Configurable performance alerts'),
        ],
      ),
      _RoleData(
        role: UserRole.principal,
        title: lang == 'gu'
            ? 'શાળા આચાર્ય (Principals)'
            : (lang == 'hi' ? 'प्रधानाचार्य (Principals)' : 'School Principals'),
        desc: lang == 'gu'
            ? 'સમગ્ર શાળાનું શૈક્ષણિક સ્તર, વર્ગવાર તુલનાત્મક પરિણામો, શૈક્ષણિક પ્રગતિના વલણો અને માર્ગદર્શન.'
            : (lang == 'hi'
                ? 'समग्र विद्यालय स्वास्थ्य, कक्षावार तुलना, शैक्षणिक सुधार के रुझान और प्रशासनिक सुझाव।'
                : 'Macro school health, classroom-wise comparisons, longitudinal academic trends, and policy suggestions.'),
        icon: Icons.apartment_rounded,
        color: const Color(0xFF1E3A8A), // Navy Blue
        features: [
          lang == 'gu' ? 'સમગ્ર શાળાનું પ્રદર્શન રજિસ્ટર' : (lang == 'hi' ? 'विद्यालय-स्तरीय प्रदर्शन रजिस्टर' : 'School-wide performance ledger'),
          lang == 'gu' ? 'ધોરણ ૧ થી ૮ સુધીનું વિશ્લેષણ' : (lang == 'hi' ? 'कक्षा 1 से 8 तक विस्तृत विश्लेषण' : 'Drill-down by Class 1 to 8'),
          lang == 'gu' ? 'FLN અને ગુણવત્તા વિતરણ' : (lang == 'hi' ? 'FLN और उत्कृष्टता वितरण' : 'FLN & Excellence distributions'),
        ],
      ),
      _RoleData(
        role: UserRole.brc,
        title: lang == 'gu'
            ? 'બ્લોક સંયોજક (BRC)'
            : (lang == 'hi' ? 'ब्लॉक समन्वयक (BRC)' : 'Block Resource Coordinators (BRC)'),
        desc: lang == 'gu'
            ? 'સમગ્ર બ્લોકની શાળાઓનું સુપરવિઝન, મોનિટરિંગ, એકેડેમિક ઓડિટ અને શિક્ષકોને પ્રશિક્ષણ તથા માર્ગદર્શન પૂરું પાડવું.'
            : (lang == 'hi'
                ? 'संपूर्ण ब्लॉक के विद्यालयों का पर्यवेक्षण, निगरानी, शैक्षणिक ऑडिट एवं सभी विद्यालयों को अकादमिक सहयोग व शिक्षक प्रशिक्षण प्रदान करना।'
                : 'Block-wide multi-school supervision, academic audit monitoring, teacher training workshops, and pedagogical support across all schools.'),
        icon: Icons.hub_rounded,
        color: const Color(0xFF0284C7), // Light Blue
        features: [
          lang == 'gu' ? 'સમગ્ર બ્લોકની શાળાઓ અને ક્લસ્ટરનું નિરીક્ષણ' : (lang == 'hi' ? 'पूरे ब्लॉक के विद्यालयों एवं क्लस्टरों का पर्यवेक्षण' : 'Block-wide multi-school supervision & cluster oversight'),
          lang == 'gu' ? 'શૈક્ષણિક તપાસણી, MDM અને FLN ઓડિટ ટ્રેકિંગ' : (lang == 'hi' ? 'विद्यालय निरीक्षण, MDM एवं FLN ऑडिट ट्रैकिंग' : 'Academic inspections, MDM & FLN audit tracking'),
          lang == 'gu' ? 'શિક્ષક તાલીમ કાર્યશાળાઓ અને શિક્ષણ નિર્દેશો' : (lang == 'hi' ? 'शिक्षण प्रशिक्षण कार्यशालाएं एवं शैक्षणिक निर्देश' : 'Teacher training workshops & pedagogical directives'),
        ],
      ),
      _RoleData(
        role: UserRole.parent,
        title: lang == 'gu'
            ? 'વાલીઓ (Parents)'
            : (lang == 'hi' ? 'अभिभावक (Parents)' : 'Parents'),
        desc: lang == 'gu'
            ? 'બાળકનું પ્રોત્સાહક પ્રગતિ પત્રક, ડેટા આધારિત ઘરેલુ પ્રવૃત્તિઓ અને શિક્ષક સાથે સીધો પ્રશ્નોત્તરી સંવાદ.'
            : (lang == 'hi'
                ? 'अपने बच्चे का उत्साहवर्धक प्रगति पत्रक, डेटा-आधारित घरेलू अभ्यास सुझाव और शिक्षक से सीधा संवाद।'
                : 'Welcoming progress cards for your child, data-backed home practice recommendations, and direct teacher queries.'),
        icon: Icons.family_restroom_rounded,
        color: const Color(0xFFD97706), // Amber
        features: [
          lang == 'gu' ? 'માત્ર પોતાના બાળકના રેકોર્ડની સુરક્ષા' : (lang == 'hi' ? 'अधिकृत लिंक्ડ बच्चे के रिकॉर्ड तक पहुंच' : 'Authorized linked child access'),
          lang == 'gu' ? 'સરળ ભાષામાં પ્રગતિ કાર્ડ' : (lang == 'hi' ? 'सरल भाषा में प्रगति रिपोर्ट' : 'Plain-language progress cards'),
          lang == 'gu' ? '૧૦ મિનિટની રમૂજી ઘરેલુ રમતો' : (lang == 'hi' ? '10-मिनट के ज्ञानवर्धक घरेलू खेल' : '10-minute home practice games'),
        ],
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isWide = width >= 840;

        if (!isWide) {
          return Column(
            children: cards.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildRoleCard(context, c),
            )).toList(),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (context, index) => _buildRoleCard(context, cards[index]),
        );
      },
    );
  }

  Widget _buildRoleCard(BuildContext context, _RoleData data) {
    final isSelected = _selectedRole == data.role;

    return Card(
      elevation: isSelected ? 2 : 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? data.color : const Color(0xFFE2E8F0),
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() => _selectedRole = data.role);
        },
        onDoubleTap: () {
          setState(() => _selectedRole = data.role);
          _navigateToLogin(context, data.role);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row: Icon circle + Radio check circle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: data.color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(data.icon, color: data.color, size: 22),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? data.color : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? data.color : const Color(0xFFCBD5E1),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                data.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 5),

              // Description
              Text(
                data.desc,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),

              // 3 Features list with check icons
              ...data.features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: Color(0xFF0D9488),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          f,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 4. CONTINUE ACTION BAR
  // ==========================================
  Widget _buildContinueActionBar(BuildContext context, String lang) {
    final selectionLabel = _getRoleDisplayName(_selectedRole, lang);
    final selectionIcon = _getRoleIcon(_selectedRole);
    final selectionColor = _getRoleColor(_selectedRole);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 14,
        runSpacing: 10,
        children: [
          // Current Selection Text
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(selectionIcon, color: selectionColor, size: 26),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lang == 'gu' ? 'હાલની પસંદગી:' : (lang == 'hi' ? 'वर्तमान चयन:' : 'CURRENT SELECTION:'),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      selectionLabel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Continue to Login Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () => _navigateToLogin(context, _selectedRole),
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: Text(
              lang == 'gu'
                  ? 'લૉગિન પર આગળ વધો'
                  : (lang == 'hi' ? 'लॉगिन के लिए आगे बढ़ें' : 'Continue to Login'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 5. STANDARDIZED PERFORMANCE COLOR SYSTEM
  // ==========================================
  Widget _buildPerformanceColorSystem(String lang) {
    final title = lang == 'gu'
        ? 'પ્રમાણભૂત શૈક્ષણિક પ્રદર્શન રંગ પ્રણાલી'
        : (lang == 'hi'
            ? 'मानकीकृत शैक्षणिक प्रदर्शन रंग प्रणाली'
            : 'Standardized Academic Performance Color System');

    final sub = lang == 'gu'
        ? 'એજ્યુટ્રેક તમામ વિષયો અને ડેશબોર્ડ પર એકસમાન પારદર્શક ત્રિ-સ્તરીય ધોરણ લાગુ કરે છે:'
        : (lang == 'hi'
            ? 'एड्यूट्रेक सभी विषयों और डैशबोर्ड पर एक समान पारदर्शी त्रि-स्तरीय मानक लागू करता है:'
            : 'EduTrack enforces a uniform, transparent three-tier mastery standard across all subjects and user dashboards:');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                const Icon(Icons.pie_chart_outline_rounded, color: Color(0xFF0D9488), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              sub,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),

            // 3 Color Tier Cards (Green, Yellow, Red)
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 720;
                final items = [
                  _buildColorTierCard(
                    badge: lang == 'gu'
                        ? 'લીલો • ઉત્કૃષ્ટ (૭૫% – ૧૦૦%)'
                        : (lang == 'hi'
                            ? 'हरा • उत्कृष्ट (75% – 100%)'
                            : 'Green • Excellent (75% – 100%)'),
                    desc: lang == 'gu'
                        ? 'પાયાના ખ્યાલો પર સંપૂર્ણ પકડ. વિદ્યાર્થી પ્રોત્સાહક પ્રવૃત્તિઓ માટે તૈયાર છે.'
                        : (lang == 'hi'
                            ? 'मूलभूत अवधारणाओं पर पूर्ण महारत। छात्र संवर्धन अभ्यासों के लिए योग्य है।'
                            : 'Full mastery of foundational concepts. Student qualifies for enrichment exercises and peer-mentoring roles.'),
                    bgColor: const Color(0xFFF2F8EF),
                    borderColor: const Color(0xFFB6DE9E),
                    textColor: const Color(0xFF274E13),
                    badgeBg: const Color(0xFF6AA84F),
                  ),
                  _buildColorTierCard(
                    badge: lang == 'gu'
                        ? 'પીળો • મધ્યમ (૪૦% – ૭૪%)'
                        : (lang == 'hi'
                            ? 'पीला • औसत (40% – 74%)'
                            : 'Yellow • Average (40% – 74%)'),
                    desc: lang == 'gu'
                        ? 'વિકાસશીલ ક્ષમતા. મુખ્ય ખ્યાલ સમજાયો છે પરંતુ નિયમિત પ્રેક્ટિસ જરૂરી છે.'
                        : (lang == 'hi'
                            ? 'प्रगतिशील दक्षता। मुख्य समझ बनी है किंतु निरंतर अभ्यास की आवश्यकता है।'
                            : 'Developing competency. Demonstrates core understanding but requires routine practice and guidance.'),
                    bgColor: const Color(0xFFFEF8F0),
                    borderColor: const Color(0xFFFCD5A8),
                    textColor: const Color(0xFFB45F06),
                    badgeBg: const Color(0xFFF6B26B),
                  ),
                  _buildColorTierCard(
                    badge: lang == 'gu'
                        ? 'લાલ • વધુ સુધારણા જરૂરી (૪૦% થી ઓછું)'
                        : (lang == 'hi'
                            ? 'लाल • अधिक सुधार अपेक्षित (40% से कम)'
                            : 'Red • Needs More Improvement (Below 40%)'),
                    desc: lang == 'gu'
                        ? 'મહત્વપૂર્ણ અધ્યયન ખામી. તાત્કાલિક શિક્ષક હસ્તક્ષેપ અને ઉપચારાત્મક શિક્ષણ જરૂરી.'
                        : (lang == 'hi'
                            ? 'गंभीर अध्ययन अंतराल। तत्काल शिक्षक मार्गदर्शन और उपचारात्मक योजना आवश्यक।'
                            : 'Critical conceptual learning gap. Automatically flagged for early teacher intervention and targeted micro-remedial plans.'),
                    bgColor: const Color(0xFFFDF2F2),
                    borderColor: const Color(0xFFF4B2B2),
                    textColor: const Color(0xFF990000),
                    badgeBg: const Color(0xFFE06666),
                  ),
                ];

                if (!isWide) {
                  return Column(
                    children: items.map((w) => Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: w,
                    )).toList(),
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items.map((w) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: w,
                    ),
                  )).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorTierCard({
    required String badge,
    required String desc,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required Color badgeBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 6. SITE FOOTER
  // ==========================================
  Widget _buildSiteFooter(String lang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  lang == 'gu' ? 'એડ્યુટ્રેક' : (lang == 'hi' ? 'एडुट्रैक' : 'EduTrack'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Text(' — ', style: TextStyle(color: Color(0xFF94A3B8))),
                Text(
                  lang == 'gu'
                      ? 'સ્માર્ટ પરફોર્મન્સ મોનિટરિંગ'
                      : (lang == 'hi'
                          ? 'स्मार्ट परफॉर्मेंस मॉनिटरिंग'
                          : 'Smart Performance Monitoring'),
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              lang == 'gu'
                  ? 'ગુજરાત પ્રાથમિક શાળાઓ માટે વિકસિત'
                  : (lang == 'hi'
                      ? 'गुजरात प्राथमिक विद्यालयों के लिए विकसित'
                      : 'Primary & Middle Education Analytics • Designed for Gujarat Primary Schools'),
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin(BuildContext context, UserRole role) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen(role: role)),
    );
  }

  String _getRoleDisplayName(UserRole role, String lang) {
    switch (role) {
      case UserRole.teacher:
        return lang == 'gu'
            ? 'શિક્ષક પોર્ટલ (Teachers Portal)'
            : (lang == 'hi' ? 'शिक्षक पोर्टल (Teachers Portal)' : 'Teachers Portal');
      case UserRole.principal:
        return lang == 'gu'
            ? 'શાળા આચાર્ય પોર્ટલ (Principals Portal)'
            : (lang == 'hi' ? 'प्रधानाचार्य पोर्टल (Principals Portal)' : 'School Principals Portal');
      case UserRole.brc:
        return lang == 'gu'
            ? 'બ્લોક સંયોજક પોર્ટલ (BRC Portal)'
            : (lang == 'hi' ? 'ब्लॉक समन्वयक पोर्टल (BRC Portal)' : 'Block Resource Coordinators Portal');
      case UserRole.parent:
        return lang == 'gu'
            ? 'વાલી પોર્ટલ (Parents Portal)'
            : (lang == 'hi' ? 'अभिभावक पोर्टल (Parents Portal)' : 'Parents Portal');
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return Icons.co_present_rounded;
      case UserRole.principal:
        return Icons.apartment_rounded;
      case UserRole.brc:
        return Icons.hub_rounded;
      case UserRole.parent:
        return Icons.family_restroom_rounded;
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return const Color(0xFF0D9488);
      case UserRole.principal:
        return const Color(0xFF1E3A8A);
      case UserRole.brc:
        return const Color(0xFF0284C7);
      case UserRole.parent:
        return const Color(0xFFD97706);
    }
  }
}

class _RoleData {
  final UserRole role;
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final List<String> features;

  const _RoleData({
    required this.role,
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
    required this.features,
  });
}
