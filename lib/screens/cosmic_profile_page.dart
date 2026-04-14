import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:country_state_city/country_state_city.dart' as csc;
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';

class CosmicProfilePage extends StatefulWidget {
  const CosmicProfilePage({super.key});

  @override
  State<CosmicProfilePage> createState() => _CosmicProfilePageState();
}

class _CosmicProfilePageState extends State<CosmicProfilePage> with TickerProviderStateMixin {
  DateTime? currentBirthDate;
  String? currentBirthTime;
  String? currentBirthPlace;
  bool _isSaving = false;
  int _daysUntilUnlock = 0;

  csc.Country? selectedCountry;

  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _countryError = false;
  // Animation controller for the map ping
  late AnimationController _mapPulseController;

  final MapController _flutterMapController = MapController();
  LatLng _mapLocation = const LatLng(0, 0);
  double _mapZoom = 1.5;

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    if (!mounted) return;
    final latTween = Tween<double>(begin: _mapLocation.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(begin: _mapLocation.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: _mapZoom, end: destZoom);

    final controller = AnimationController(duration: const Duration(milliseconds: 1800), vsync: this);
    final Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic);

    controller.addListener(() {
      _flutterMapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  Future<void> _geocodeAndMoveMap(String query) async {
    if (query.isEmpty) return;
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1');
      final req = await http.get(url, headers: {'User-Agent': 'VluckyApp/1.0'});
      if (req.statusCode == 200) {
        final List data = json.decode(req.body);
        if (data.isNotEmpty) {
          final lat = double.tryParse(data[0]['lat'].toString()) ?? 0;
          final lon = double.tryParse(data[0]['lon'].toString()) ?? 0;
          if (mounted) {
            final dest = LatLng(lat, lon);
            // Zoom tight for cities/villages, zoom out (4.0) for whole countries
            final z = query.contains(',') ? 7.0 : 4.0; 
            _animatedMapMove(dest, z);
            setState(() {
              _mapLocation = dest;
              _mapZoom = z;
            });
          }
        }
      }
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _mapPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: false);

    _loadData();
  }

  @override
  void dispose() {
    _countryController.dispose();
    _locationController.dispose();
    _mapPulseController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final date = await StorageService.getBirthDate();
    final time = await StorageService.getBirthTime();
    final place = await StorageService.getBirthPlace();
    
    // Fetch countries offline array to remap previously saved string
    final countries = await csc.getAllCountries();

    final prefs = await SharedPreferences.getInstance();
    final lastUpdateStr = prefs.getString('last_cosmic_profile_update');
    // if (lastUpdateStr != null) {
    //   final lastUpdate = DateTime.parse(lastUpdateStr);
    //   final daysPassed = DateTime.now().difference(lastUpdate).inDays;
    //   if (daysPassed < 30) {
    //     _daysUntilUnlock = 30 - daysPassed;
    //   }
    // }
    _daysUntilUnlock = 0; // ŞİMDİLİK TEST İÇİN KALDIRILDI

    if (mounted) {
      setState(() {
        currentBirthDate = date;
        currentBirthTime = (time != null && time.isNotEmpty) ? time : null;
        currentBirthPlace = (place != null && place.isNotEmpty) ? place : null;
        if (currentBirthPlace != null) {
          final String validPlace = currentBirthPlace!;
          final parts = validPlace.split(',').map((e) => e.trim()).toList();
          if (parts.isNotEmpty) {
            try {
              selectedCountry = countries.firstWhere((c) => c.name.toLowerCase() == parts[0].toLowerCase());
              if (parts.length > 1) {
                _locationController.text = parts.sublist(1).join(', ');
              }
            } catch (_) {
              selectedCountry = null;
              _locationController.clear();
            }
          }
          String searchQ = validPlace;
          // If it's saved as "China, Makit County, Xinjiang...", shift it for map search
          if (parts.length > 2) {
             searchQ = parts.sublist(1).join(', ');
          }
          _geocodeAndMoveMap(searchQ);
        }
      });
    }
  }

  void _updateCombinedPlace() {
    final country = selectedCountry?.name ?? '';
    final loc = _locationController.text.trim();

    List<String> valid = [];
    if (country.isNotEmpty) valid.add(country);
    if (loc.isNotEmpty) valid.add(loc);
     
    final combined = valid.join(', ');
    setState(() => currentBirthPlace = combined.isEmpty ? null : combined);
    if (combined.isNotEmpty) {
      
      // Nominatim search logic gets confused if Country comes before City.
      // So if 'loc' exists, use it (and append country if it's just a single word).
      String searchQ = combined;
      if (loc.isNotEmpty) {
        searchQ = loc.contains(',') ? loc : '$loc, $country'; 
      } else if (country.isNotEmpty) {
        searchQ = country;
      }
      
      _geocodeAndMoveMap(searchQ);
    }
  }

  void _showSearchModal(String title, List<dynamic> items, Function(dynamic) onSelect) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SearchModal(
          title: title,
          items: items,
          onSelect: onSelect,
        );
      },
    );
  }


  void _showLiveLocationModal() {
    final lang = Localizations.localeOf(context).languageCode;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _LiveLocationSearchModal(
          countryCode: selectedCountry?.isoCode,
          onSelect: (String exactLocation) {
            setState(() {
              _locationController.text = exactLocation;
            });
            _updateCombinedPlace();
          },
        );
      },
    );
  }

  String getWesternZodiac(DateTime? d) {
    if (d == null) return '-';
    final lang = Localizations.localeOf(context).languageCode;
    final month = d.month;
    final day = d.day;
    final signs = lang == 'tr'
        ? ['Oğlak', 'Kova', 'Balık', 'Koç', 'Boğa', 'İkizler', 'Yengeç', 'Aslan', 'Başak', 'Terazi', 'Akrep', 'Yay', 'Oğlak']
        : ['Capricorn', 'Aquarius', 'Pisces', 'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn'];
    const cutoffs = [20, 19, 20, 20, 21, 21, 23, 23, 23, 23, 22, 22];
    return day < cutoffs[month - 1] ? signs[month - 1] : signs[month];
  }

  String getChineseZodiac(DateTime? d) {
    if (d == null) return '-';
    final lang = Localizations.localeOf(context).languageCode;
    final animals = lang == 'tr'
        ? ['Fare', 'Öküz', 'Kaplan', 'Tavşan', 'Ejderha', 'Yılan', 'At', 'Keçi', 'Maymun', 'Horoz', 'Köpek', 'Domuz']
        : ['Rat', 'Ox', 'Tiger', 'Rabbit', 'Dragon', 'Snake', 'Horse', 'Goat', 'Monkey', 'Rooster', 'Dog', 'Pig'];
    return animals[(d.year - 4) % 12];
  }

  String getMayanZodiac(DateTime? d) {
    if (d == null) return '-';
    final lang = Localizations.localeOf(context).languageCode;
    final mayanSigns = lang == 'tr'
        ? ['Timsah', 'Rüzgar', 'Gece', 'Tohum', 'Yılan', 'Ölüm', 'Geyik', 'Yıldız', 'Su', 'Köpek', 'Maymun', 'Yol', 'Saz', 'Jaguar', 'Kartal', 'Baykuş', 'Toprak', 'Ayna', 'Fırtına', 'Güneş']
        : ['Crocodile', 'Wind', 'Night', 'Seed', 'Serpent', 'Death', 'Deer', 'Star', 'Water', 'Dog', 'Monkey', 'Road', 'Reed', 'Jaguar', 'Eagle', 'Owl', 'Earth', 'Mirror', 'Storm', 'Sun'];
    final pseudoIndex = (d.month * d.day + d.year) % 20;
    return mayanSigns[pseudoIndex];
  }

  String getAscendant(DateTime? d, String? time) {
    if (d == null || time == null || time.isEmpty) return Localizations.localeOf(context).languageCode == 'tr' ? 'Saat Gerekli' : 'Requires Time';
    final lang = Localizations.localeOf(context).languageCode;
    final signsTr = ['Koç', 'Boğa', 'İkizler', 'Yengeç', 'Aslan', 'Başak', 'Terazi', 'Akrep', 'Yay', 'Oğlak', 'Kova', 'Balık'];
    final signsEn = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];
    
    final h = int.tryParse(time.split(':')[0]) ?? 12;
    final m = int.tryParse(time.split(':')[1]) ?? 0;
    final index = (d.month * 2 + d.day + h + (m ~/ 15)) % 12;
    return lang == 'tr' ? signsTr[index] : signsEn[index];
  }

  // Generate pseudo coordinates for aesthetic map display
  String getCoordinates(String? place) {
    if (place == null || place.isEmpty) return '00°00\'00"N 00°00\'00"E';
    final hash = place.hashCode;
    final lat = (hash % 90).abs();
    final lng = ((hash ~/ 90) % 180).abs();
    final latDir = (hash % 2 == 0) ? 'N' : 'S';
    final lngDir = (hash % 3 == 0) ? 'W' : 'E';
    return '${lat.toString().padLeft(2, '0')}°${(hash % 60).toString().padLeft(2, '0')}\'12"$latDir  ${lng.toString().padLeft(2, '0')}°${(hash % 60).toString().padLeft(2, '0')}\'44"$lngDir';
  }

  Widget _buildTopLiveSummary(String lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8, bottom: 20, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.01),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildSummaryNode(
                lang == 'tr' ? 'BATI' : 'WESTERN',
                getWesternZodiac(currentBirthDate),
                const Color(0xFFC084FC),
                Icons.flare_outlined,
              ),
              _buildSummaryNode(
                lang == 'tr' ? 'ASYA' : 'ASIAN',
                getChineseZodiac(currentBirthDate),
                const Color(0xFFFF6B6B),
                Icons.brightness_medium_outlined,
              ),
              _buildSummaryNode(
                lang == 'tr' ? 'MAYA' : 'MAYAN',
                getMayanZodiac(currentBirthDate),
                const Color(0xFF2DD4BF),
                Icons.filter_vintage_outlined,
              ),
              _buildSummaryNode(
                lang == 'tr' ? 'YÜKSELEN' : 'RISING',
                getAscendant(currentBirthDate, currentBirthTime),
                const Color(0xFF60A5FA),
                Icons.north_east_rounded,
              ),
            ],
          ),
          if (currentBirthTime == null || currentBirthPlace == null || currentBirthPlace!.isEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 14, color: Colors.white.withOpacity(0.3)),
                const SizedBox(width: 8),
                Text(
                  lang == 'tr'
                      ? 'Yükselen burç ve tam harita analizi için saat ve yer gereklidir.'
                      : 'Time and place are required for Ascendant and full chart analysis.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 11,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSummaryNode(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color.withOpacity(0.6), size: 16),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final inAnimation = Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(animation);
              final outAnimation = Tween<Offset>(begin: const Offset(0.0, -0.5), end: Offset.zero).animate(animation);

              return SlideTransition(
                position: child.key == ValueKey<String>(value) ? inAnimation : outAnimation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Text(
              value,
              key: ValueKey<String>(value),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSelector(String hint, String value, VoidCallback? onTap, {VoidCallback? onClear, bool hasError = false}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: hasError ? Colors.red.withOpacity(0.1) : Colors.transparent,
          border: Border(bottom: BorderSide(color: hasError ? Colors.redAccent : (onTap == null ? Colors.white.withOpacity(0.05) : const Color(0xFF2DD4BF)))),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hint.toUpperCase(),
              style: TextStyle(
                color: hasError ? Colors.redAccent : (onTap == null ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.3)),
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value.isEmpty ? 'Seç' : value,
                    style: TextStyle(
                      color: hasError ? Colors.redAccent.withOpacity(0.8) : (value.isEmpty ? Colors.white.withOpacity(0.2) : Colors.white),
                      fontSize: 13,
                      fontWeight: value.isEmpty ? FontWeight.w300 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (value.isNotEmpty && onClear != null)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onClear();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.3), size: 16),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Container(
          height: 1,
          width: 40,
          color: Colors.white.withOpacity(0.1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    
    return Scaffold(
      backgroundColor: Colors.transparent, // Allow underlying page to show through with SwipeFadePageRoute
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Full Screen Blur Layer
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                color: Colors.black.withOpacity(0.35), // Çok daha şeffaf glass panel
              ),
            ),
          ),
          
          // 2. Ambient Glow Backgrounds
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFC084FC).withOpacity(0.12),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox(),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2DD4BF).withOpacity(0.08),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox(),
              ),
            ),
          ),

          // 3. UI Content
          // 3. UI Content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Custom AppBar inside the body matches glass UI perfectly
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        lang == 'tr' ? 'Kozmik Harita' : 'Cosmic Chart',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(width: 48), // Balance for title centering
                    ],
                  ),
                ),
            // Always fixed at the very top: The Live Summary!
            _buildTopLiveSummary(lang),
            
            // Scrollable forms
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                children: [
                  
                  // ── DATE SECTION ──
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang == 'tr' ? 'DÜNYAYA İNİŞ TARİHİ' : 'ARRIVAL DATE',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currentBirthDate == null
                                ? '--.--.----'
                                : '${currentBirthDate!.day.toString().padLeft(2, '0')}.${currentBirthDate!.month.toString().padLeft(2, '0')}.${currentBirthDate!.year}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 130,
                        child: IgnorePointer(
                          ignoring: _daysUntilUnlock > 0,
                          child: CupertinoTheme(
                          data: CupertinoThemeData(
                            brightness: Brightness.dark,
                            textTheme: CupertinoTextThemeData(
                              dateTimePickerTextStyle: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.date,
                            initialDateTime: currentBirthDate ?? DateTime(2000, 1, 1),
                            minimumDate: DateTime(1920),
                            maximumDate: DateTime.now(),
                            selectionOverlayBuilder: (context, {required int columnCount, required int selectedIndex}) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.symmetric(horizontal: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
                                ),
                              );
                            },
                            onDateTimeChanged: (date) {
                              HapticFeedback.selectionClick();
                              setState(() => currentBirthDate = date);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                  ),
                  
                  _buildDivider(),

                  // ── TIME SECTION ──
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            lang == 'tr' ? 'DOĞUM SAATİ' : 'BIRTH TIME',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
                          if (currentBirthTime != null)
                            GestureDetector(
                              onTap: _daysUntilUnlock > 0 ? null : () {
                                HapticFeedback.selectionClick();
                                setState(() => currentBirthTime = null);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                                ),
                                child: Text(
                                  lang == 'tr' ? 'Saat Bilinmiyor' : 'Time Unknown',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85), 
                                    fontSize: 10, 
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currentBirthTime ?? '--:--',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 120,
                        child: IgnorePointer(
                          ignoring: _daysUntilUnlock > 0,
                          child: CupertinoTheme(
                          data: CupertinoThemeData(
                            brightness: Brightness.dark,
                            textTheme: CupertinoTextThemeData(
                              dateTimePickerTextStyle: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 18),
                            ),
                          ),
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.time,
                            use24hFormat: true,
                            initialDateTime: currentBirthTime != null
                                ? DateTime(
                                    2000, 1, 1,
                                    int.tryParse(currentBirthTime!.split(':')[0]) ?? 12,
                                    int.tryParse(currentBirthTime!.split(':')[1]) ?? 0,
                                  )
                                : DateTime(2000, 1, 1, 12, 0),
                            selectionOverlayBuilder: (context, {required int columnCount, required int selectedIndex}) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.symmetric(horizontal: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
                                ),
                              );
                            },
                            onDateTimeChanged: (time) {
                              HapticFeedback.selectionClick();
                              final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                              setState(() => currentBirthTime = timeStr);
                            },
                          ),
                        ),
                        ),
                      ),
                    ],
                  ),

                  _buildDivider(),

                  // ── PLACE SECTION ──
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang == 'tr' ? 'DOĞUM YERİ KOORDİNATLARI' : 'BIRTH PLACE COORDINATES',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 2 Fields Only: Country (Select) + City/District (Free Text)
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: _buildLocationSelector(
                              lang == 'tr' ? 'Ülke' : 'Country',
                              selectedCountry?.name ?? '',
                              () async {
                                if (_daysUntilUnlock > 0) return;
                                final countries = await csc.getAllCountries();
                                _showSearchModal(lang == 'tr' ? 'Ülke Seç' : 'Select Country', countries, (item) {
                                  setState(() {
                                    selectedCountry = item;
                                    _locationController.clear();
                                    _countryError = false;
                                  });
                                  _updateCombinedPlace();
                                });
                              },
                              hasError: _countryError,
                              onClear: _daysUntilUnlock > 0 ? null : () {
                                setState(() {
                                  selectedCountry = null;
                                  _locationController.clear();
                                });
                                _updateCombinedPlace();
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 6,
                            child: _buildLocationSelector(
                              lang == 'tr' ? 'Şehir & İlçe & Köy' : 'City & District & Village',
                              _locationController.text,
                              () {
                                if (_daysUntilUnlock > 0) return;
                                if (selectedCountry == null) {
                                  HapticFeedback.heavyImpact();
                                  setState(() => _countryError = true);
                                  Future.delayed(const Duration(milliseconds: 800), () {
                                    if (mounted) setState(() => _countryError = false);
                                  });
                                  return;
                                }
                                _showLiveLocationModal();
                              },
                              onClear: _daysUntilUnlock > 0 ? null : () {
                                setState(() {
                                  _locationController.clear();
                                });
                                _updateCombinedPlace();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Dark Atmospheric Live Map
                      Container(
                        height: 180,
                        width: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: const Color(0xFF030406),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Actual Flutter Map
                            FlutterMap(
                              mapController: _flutterMapController,
                              options: MapOptions(
                                initialCenter: _mapLocation,
                                initialZoom: _mapZoom,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png',
                                  subdomains: const ['a', 'b', 'c', 'd'],
                                  userAgentPackageName: 'com.vlucky.app',
                                ),
                              ],
                            ),
                            
                            // Cosmic Vignette (Portal Edge Fade)
                            IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    center: Alignment.center,
                                    radius: 0.9,
                                    colors: [
                                      Colors.transparent,
                                      const Color(0xFF030406).withOpacity(0.5),
                                      const Color(0xFF030406).withOpacity(0.95),
                                    ],
                                    stops: const [0.4, 0.8, 1.0],
                                  ),
                                ),
                              ),
                            ),
                            
                            // Map Center Ping
                            if (currentBirthPlace != null && currentBirthPlace!.isNotEmpty)
                              AnimatedBuilder(
                                animation: _mapPulseController,
                                builder: (context, child) {
                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 14 + (_mapPulseController.value * 40),
                                        height: 14 + (_mapPulseController.value * 40),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFF2DD4BF).withOpacity(1.0 - _mapPulseController.value),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF2DD4BF),
                                          shape: BoxShape.circle,
                                          boxShadow: [BoxShadow(color: Color(0xFF2DD4BF), blurRadius: 10)],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),

                            // Coordinates Text overlay
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: AnimatedOpacity(
                                opacity: currentBirthPlace != null && currentBirthPlace!.isNotEmpty ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 500),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                                  ),
                                  child: Text(
                                    '${_mapLocation.latitude.toStringAsFixed(4)}°N  ${_mapLocation.longitude.toStringAsFixed(4)}°E',
                                    style: const TextStyle(
                                      fontFamily: 'Courier',
                                      color: Color(0xFF2DD4BF),
                                      fontSize: 10,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // ── POWERFUL CTA ──
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : () async {
                        if (_daysUntilUnlock > 0) return; // Locked

                        if (currentBirthDate == null) {
                          HapticFeedback.heavyImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                lang == 'tr' ? 'Lütfen önce doğum tarihinizi seçin.' : 'Please select your birth date first.',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              backgroundColor: Colors.redAccent.withOpacity(0.9),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                          return; // Stop here, do not save!
                        }

                        HapticFeedback.selectionClick();
                        setState(() {
                          _isSaving = true;
                        });
                        
                        // StorageService kayıtları anlık yapılmaktan çıkarıldı, sadece Kaydet diyince kalıcı oluyor
                        if (currentBirthDate != null) {
                          await StorageService.setBirthDate(currentBirthDate!);
                          await StorageService.setZodiacSign(getWesternZodiac(currentBirthDate));
                        }
                        await StorageService.setBirthTime(currentBirthTime ?? '');
                        await StorageService.setBirthPlace(currentBirthPlace ?? '');

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('last_cosmic_profile_update', DateTime.now().toIso8601String());
                        
                        await Future.delayed(const Duration(milliseconds: 1500));
                        
                        if (context.mounted) {
                          Navigator.pop(context, true); // True döndürerek uygulamanın güncellenmesini tetikle
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _daysUntilUnlock > 0 ? Colors.white.withOpacity(0.1) : Colors.white,
                        foregroundColor: _daysUntilUnlock > 0 ? Colors.white.withOpacity(0.4) : Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isSaving 
                        ? const CupertinoActivityIndicator(color: Colors.black)
                        : Text(
                            _daysUntilUnlock > 0 
                                ? (lang == 'tr' ? '$_daysUntilUnlock Gün Sonra Değiştirilebilir' : 'Locked for $_daysUntilUnlock Days')
                                : (lang == 'tr' ? 'Kaydet' : 'Save'),
                            style: TextStyle(
                              fontWeight: _daysUntilUnlock > 0 ? FontWeight.w500 : FontWeight.w700,
                              fontSize: _daysUntilUnlock > 0 ? 14 : 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.paddingOf(context).bottom + 16),
                ],
              ),
            ),
          ],
        ),
      ),
      ],
    ),
  );
  }
}

// Map pseudo grid painter to add "Map Review" atmospheric aesthetic
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.5;

    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SearchModal extends StatefulWidget {
  final String title;
  final List<dynamic> items;
  final Function(dynamic) onSelect;
  final bool allowCustom;

  const _SearchModal({required this.title, required this.items, required this.onSelect, this.allowCustom = false});

  @override
  State<_SearchModal> createState() => _SearchModalState();
}

class _SearchModalState extends State<_SearchModal> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items.where((e) => e.name.toString().toLowerCase().contains(_query.toLowerCase())).toList();
    final hasExactMatch = filtered.any((e) => e.name.toString().toLowerCase() == _query.toLowerCase());
    
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.55,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.2))),
          ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Ara...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (val) => setState(() => _query = val),
            ),
          ),
          const SizedBox(height: 16),
          // Custom entry option when allowCustom is true
          if (widget.allowCustom && _query.trim().isNotEmpty && !hasExactMatch)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                leading: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2DD4BF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add_rounded, color: Color(0xFF2DD4BF), size: 18),
                ),
                title: Text(
                  '"${_query.trim()}"',
                  style: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  Localizations.localeOf(context).languageCode == 'tr' ? 'Bunu ekle' : 'Add this',
                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
                ),
                onTap: () {
                  widget.onSelect(_query.trim());
                  Navigator.pop(context);
                },
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final item = filtered[i];
                return ListTile(
                  title: Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                    widget.onSelect(item);
                  },
                );
              },
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}

// ==========================================
// LIVE GEOCODING (OSM NOMINATIM) MODAL 
// ==========================================
class _LiveLocationSearchModal extends StatefulWidget {
  final String? countryCode;
  final Function(String) onSelect;

  const _LiveLocationSearchModal({this.countryCode, required this.onSelect});

  @override
  State<_LiveLocationSearchModal> createState() => _LiveLocationSearchModalState();
}

class _LiveLocationSearchModalState extends State<_LiveLocationSearchModal> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  List<String> _results = [];
  List<String> _defaultResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDefaultCities();
  }

  Future<void> _loadDefaultCities() async {
    if (widget.countryCode == null) return;
    setState(() => _isLoading = true);
    try {
      final cities = await csc.getCountryCities(widget.countryCode!);
      if (mounted) {
        setState(() {
          _defaultResults = cities.map((e) => e.name).toList();
          _results = _defaultResults.take(100).toList(); // Show first 100 to avoid lag
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    final lcQuery = query.toLowerCase();
    if (lcQuery.trim().isEmpty) {
      setState(() {
        _results = _defaultResults.take(100).toList();
        _isLoading = false;
      });
      return;
    }

    // Instant local filter from offline database
    setState(() {
      _results = _defaultResults
          .where((name) => name.toLowerCase().contains(lcQuery))
          .take(50) // limit local results for speed
          .toList();
      _isLoading = true;
    });

    // Fallback to Live Geocoding API after 800ms to catch unlisted villages
    _debounce = Timer(const Duration(milliseconds: 800), () async {
      try {
        // Force pure 'en' (English/Latin) so the API NEVER returns native scripts like Chinese or Arabic, which our custom font cannot render (causes [?][?][?])
        String url = 'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&accept-language=en';
        if (widget.countryCode != null) {
          url += '&countrycodes=${widget.countryCode!.toLowerCase()}';
        }

        final response = await http.get(
          Uri.parse(url),
          headers: {'User-Agent': 'CosmicWishApp/1.0'},
        );

        if (response.statusCode == 200) {
          final List data = json.decode(response.body);
          final List<String> apiResults = [];
          for (var item in data) {
            final name = item['display_name'];
            if (name != null) apiResults.add(name);
          }
          
          if (mounted) {
            setState(() {
              // Combine unique local matches with API matches
              for (var res in apiResults) {
                if (!_results.contains(res)) {
                  _results.add(res);
                }
              }
              _isLoading = false;
            });
          }
        } else {
          if (mounted) setState(() => _isLoading = false);
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.55,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.2))),
          ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text(lang == 'tr' ? 'Tam Konumu Ara' : 'Search Exact Location', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: lang == 'tr' ? 'Köy, ilçe veya şehir yaz...' : 'Enter village, district, etc...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                suffixIcon: _isLoading 
                    ? const Padding(padding: EdgeInsets.all(12), child: CupertinoActivityIndicator(radius: 10))
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: _onSearchChanged,
              onSubmitted: (val) {
                 if(val.trim().isNotEmpty) {
                    widget.onSelect(val.trim());
                    Navigator.pop(context);
                 }
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Fallback free-text option if the API misses it
          if (_controller.text.trim().isNotEmpty && !_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                leading: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: const Color(0xFF2DD4BF).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.add_rounded, color: Color(0xFF2DD4BF), size: 18),
                ),
                title: Text('"${_controller.text.trim()}"', style: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text(lang == 'tr' ? 'Serbest metin olarak ekle' : 'Add as free text', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11)),
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.pop(context);
                  widget.onSelect(_controller.text.trim());
                },
              ),
            ),

          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, i) {
                return ListTile(
                  leading: const Icon(Icons.location_on_outlined, color: Colors.white54, size: 20),
                  title: Text(_results[i], style: const TextStyle(color: Colors.white, fontSize: 13)),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                    widget.onSelect(_results[i]);
                  },
                );
              },
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}


