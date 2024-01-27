import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../ Feed/MyZoneCell.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  PageController _pageController = PageController(initialPage: 0);
  ProfileFilterOptions _selectedFilter = ProfileFilterOptions.zones;

  final String username = "vaniev";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(username),
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/me.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Azamat Vaniev",
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
    List<MyZoneCell> myZones = List.generate(
      10,
          (index) => MyZoneCell(),
    );

    return ListView(
      children: myZones,
    );
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
    final Uri _url = Uri.parse('https://t.me/vizzieappp');

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