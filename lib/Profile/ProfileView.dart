import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:teen/%20Feed/LastZones.dart';
import 'package:teen/Models/Zone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ Feed/ZoneCell.dart';

Color backgroundColor = Color(0xFF1A1A1A);
Color color1 = Color(0xFF282828);
Color unselectedIconColor = Color(0xFF757575);
Color customWhite = Color(0xFFCDD0CF);

enum ProfileFilterOptions { zones, settings }

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

void _logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('authToken');
  await prefs.clear(); // Очистить все сохраненные данные

  Navigator.pushReplacementNamed(context, '/login');
}

class _ProfileViewState extends State<ProfileView> {
  String? _username = '';
  String? _fullname = '';
  String userSelectedImagePath = '';
  List<Zone> zones = [];

  List<Zone> parseZones(String responseBody) {
    final List<dynamic> parsed = json.decode(responseBody);
    return parsed.map<Zone>((json) => Zone.fromJson(json)).toList();
  }

  PageController _pageController = PageController(initialPage: 0);
  ProfileFilterOptions _selectedFilter = ProfileFilterOptions.zones;



  @override
  void initState() {
    super.initState();
    getProfileImagePath().then((path) {
      setState(() {
        userSelectedImagePath = path;
      });
    });
    loadUserWishes();
    loadUsername();
  }

  Future<void> loadUsername() async {
    final token = await _getToken();
    if (token != null) {
      final decodedToken = JwtDecoder.decode(token);
      final username = decodedToken['username'];
      final fullname = decodedToken['firstNameLastName'];
      setState(() {
        _username = username;
        _fullname = fullname;
      });
    }
  }

  Future<void> loadUserWishes() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse(
          'http://192.168.0.14:3000/user/zones'), // Замените на ваш URL сервера
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Распарсите список желаний из response.body и сохраните их в состояние
      final List<Zone> userZones = parseZones(response.body);

      userZones.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      setState(() {
        zones = userZones;
      });
    } else {
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<String> getProfileImagePath() async {
    final token = await _getToken();
    if (token != null) {
      final decodedToken = JwtDecoder.decode(token);
      final userSelectedImagePath = decodedToken['selectedImagePath'];
      return userSelectedImagePath;
    } else {
      return 'assets/logo.png';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_username ?? ""),
        foregroundColor: customWhite,
        centerTitle: true,
        backgroundColor: backgroundColor,
      ),
      body: Container(
        color: backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 106,
                height: 106,
                child: CachedNetworkImage(
                  imageUrl: 'http://192.168.0.14:3000/${userSelectedImagePath}',
                  placeholder: (context, url) => CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(customGreen)), // Замените это на ваш загрузочный индикатор
                  errorWidget: (context, url, error) => Icon(Icons.error), // Замените это на ваш виджет ошибки
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: Text(
                  _fullname ?? "",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: customWhite,
                  ),
                ),
              ),
              SizedBox(height: 16),
              _buildFilterButtons(),
              SizedBox(height: 10),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  children: [
                    _buildWishesPage(),
                    _buildSettingsPage(),
                  ],
                  onPageChanged: (int index) {
                    setState(() {
                      _selectedFilter = ProfileFilterOptions.values[index];
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildWishesPage() {
    return zones.isEmpty
        ? Center(
      child: Text(
        "Вы пока не создали ни одну зону",
        style: TextStyle(
          fontSize: 18.0,
          color: customWhite,
        ),
      ),
    )
        : ListView(
      children: _buildZonesList(zones),
    );
  }

  List<Widget> _buildZonesList(List<Zone> zoneList) {
    return zoneList.map((zone) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Container(
          child: ZoneCell(zone: zone),
        ),
      );
    }).toList();
  }

  Widget _buildSettingsPage() {
    return ListView(
      children: _buildSettingsList(),
    );
  }

  List<Widget> _buildSettingsList() {
    return SettingViewModel.values.map((viewModel) {
      if (viewModel == SettingViewModel.logout) {
        return SettingOptionView(
          viewModel: viewModel,
          onLogout: () => _logout(context),
        );
      } else {
        return SettingOptionView(viewModel: viewModel);
      }
    }).toList();
  }

  Widget _buildFilterButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ProfileFilterOptions.values.map((option) {
        return _buildFilterButton(option);
      }).toList(),
    );
  }

  Widget _buildFilterButton(ProfileFilterOptions option) {
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          option.index,
          duration: Duration(
            milliseconds: 500,
          ),
          curve: Curves.easeInOut,
        );
      },
      child: Column(
        children: [
          Text(
            getLocalizedFilterName(option),
            style: TextStyle(
              fontSize: 16,
              color: _selectedFilter == option ? customWhite : unselectedIconColor,
            ),
          ),
          SizedBox(height: 8),
          if (_selectedFilter == option)
            Container(
              height: 4,
              width: 20,
              color: customWhite,
            ),
        ],
      ),
    );
  }

  String getLocalizedFilterName(ProfileFilterOptions option) {
    switch (option) {
      case ProfileFilterOptions.zones:
        return "Мои созданные зоны";
      case ProfileFilterOptions.settings:
        return "Настройки";
    }
  }
}




class SettingOptionView extends StatelessWidget {
  final SettingViewModel viewModel;
  final VoidCallback? onLogout;

  SettingOptionView({required this.viewModel, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 25),
      decoration: BoxDecoration(
        color: color1,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          viewModel.iconData,
          color: customWhite,
        ),
        title: Text(
          viewModel.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: customWhite,
          ),
        ),
        onTap: () {
          if (viewModel == SettingViewModel.logout && onLogout != null) {
            onLogout!();
          } else {
            viewModel.onTap(context);
          }
        },
      ),
    );
  }
}


enum SettingViewModel {
  aboutApp,
  blacklist,
  safety,
  polytic,
  telegram,
  logout,
}

extension SettingViewModelExtension on SettingViewModel {
  String get title {
    switch (this) {
      case SettingViewModel.aboutApp:
        return "О нас";
      case SettingViewModel.blacklist:
        return "Черный список";
      case SettingViewModel.safety:
        return "Безопасность";
      case SettingViewModel.polytic:
        return "Политика конфиденциальности";
      case SettingViewModel.telegram:
        return "Подписаться на канал";
      case SettingViewModel.logout:
        return "Выход";
    }
  }

  IconData get iconData {
    switch (this) {
      case SettingViewModel.aboutApp:
        return FontAwesomeIcons.circleInfo;
      case SettingViewModel.blacklist:
        return FontAwesomeIcons.ban;
      case SettingViewModel.safety:
        return FontAwesomeIcons.lock;
      case SettingViewModel.polytic:
        return FontAwesomeIcons.userShield;
      case SettingViewModel.telegram:
        return FontAwesomeIcons.telegram;
      case SettingViewModel.logout:
        return FontAwesomeIcons.arrowRightFromBracket;
    }
  }

  void onTap(BuildContext context) {
    //final Uri _url = Uri.parse('https://t.me/vizzieappp');

    //Future<void> _launchUrl() async {
    //if (!await launchUrl(_url)) {
    //throw Exception('Could not launch $_url');
    //}
    //}

    switch (this) {
      case SettingViewModel.aboutApp:
        Navigator.pushNamed(context, '/aboutUs');
        break;
      case SettingViewModel.blacklist:
      // _showSnackBar(context, "Черный список скоро будет доступен");
      //Navigator.of(context).push(
      //MaterialPageRoute(
      //builder: (context) => BlackListView(),
      //),
      //);
        break;
      case SettingViewModel.safety:
        Navigator.pushNamed(context, '/safety');
        //_showSnackBar(context, "Безопасность скоро будет доступна");
        break;
      case SettingViewModel.polytic:
        Navigator.pushNamed(context, '/privacyView');
        break;
      case SettingViewModel.telegram:
      //_launchUrl();
        break;

      case SettingViewModel.logout:
        break;
    }
  }
}