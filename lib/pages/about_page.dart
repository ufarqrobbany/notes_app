import 'package:notes_app/common/constants.dart';
import 'package:notes_app/widgets/small_appbar.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:notes_app/helpers/globals.dart' as globals;

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String appName = '';
  String packageName = '';
  String version = '';
  String buildNumber = '';

  @override
  void initState() {
    getAppInfo();
    _initPackageInfo();
    super.initState();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  }

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = (globals.themeMode == ThemeMode.dark ||
        (brightness == Brightness.dark &&
            globals.themeMode == ThemeMode.system));
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: SAppBar(
          title: Text('About'),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        padding: EdgeInsets.all(10),
        child: ListView(
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          children: [
            Padding(
              padding: kGlobalOuterPadding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(70),
                    child: Image.asset(
                      'images/n_o_t_e_s.png',
                      height: 60,
                    ),
                  ),
                  SizedBox(
                    width: 3,
                  ),
                  Container(
                      alignment: Alignment.center,
                      child: Text(
                        kAppName.replaceAll('n ', ''),
                        style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 35,
                            fontWeight: FontWeight.w900),
                      )),
                ],
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(15.0),
              onTap: () {},
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(Iconsax.cpu),
                ),
                title: Text('App Version'),
                subtitle: Text(_packageInfo.version),
              ),
            ),
            Padding(
              padding: kGlobalOuterPadding,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  'Contributors',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(15.0),
              onTap: () async {
                if (await canLaunch('https://twitter.com/HammDmob')) {
                  await launch(
                    'https://twitter.com/HammDmob',
                    forceSafariVC: false,
                    forceWebView: false,
                  );
                } else {
                  throw 'Could not launch';
                }
              },
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(Iconsax.user),
                ),
                title: Text('Hamm D Mob'),
                subtitle: Text('Mobile UI Developer'),
              ),
            ),
            // InkWell(
            //   borderRadius: BorderRadius.circular(15.0),
            //   onTap: () async {
            //     if (await canLaunch('https://gitlab.com/zhanora.s.hanan')) {
            //       await launch(
            //         'https://gitlab.com/zhanora.s.hanan',
            //         forceSafariVC: false,
            //         forceWebView: false,
            //       );
            //     } else {
            //       throw 'Could not launch';
            //     }
            //   },
            //   child: ListTile(
            //     leading: CircleAvatar(
            //       child: Icon(Iconsax.user),
            //     ),
            //     title: Text('Hammam Hanan'),
            //     subtitle: Text('UI Design'),
            //   ),
            // ),
            Padding(
              padding: kGlobalOuterPadding,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  'Links',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            // InkWell(
            //   borderRadius: BorderRadius.circular(15.0),
            //   onTap: () async {
            //     if (await canLaunch('https://t.me/srawlapp')) {
            //       await launch(
            //         'https://t.me/srawlapp',
            //         forceSafariVC: false,
            //         forceWebView: false,
            //       );
            //     } else {
            //       throw 'Could not launch';
            //     }
            //   },
            //   child: ListTile(
            //     leading: CircleAvatar(
            //       child: Icon(LineIcons.telegram),
            //     ),
            //     title: Text('Telegram Channel'),
            //     subtitle: Text('Latest news about \'scrawl\''),
            //   ),
            // ),
            // InkWell(
            //   borderRadius: BorderRadius.circular(15.0),
            //   onTap: () async {
            //     if (await canLaunch('https://paypal.me/nandanrmenon')) {
            //       await launch(
            //         'https://paypal.me/nandanrmenon',
            //         forceSafariVC: false,
            //         forceWebView: false,
            //       );
            //     } else {
            //       throw 'Could not launch';
            //     }
            //   },
            //   child: ListTile(
            //     leading: CircleAvatar(
            //       child: Icon(LineIcons.github),
            //     ),
            //     title: Text('Github'),
            //     subtitle: Text('Check out our source code'),
            //   ),
            // ),
            // InkWell(
            //   borderRadius: BorderRadius.circular(15.0),
            //   onTap: () async {
            //     if (await canLaunch(
            //         'https://github.com/rsoft-in/scrawl/issues/new')) {
            //       await launch(
            //         'https://github.com/rsoft-in/scrawl/issues/new',
            //         forceSafariVC: false,
            //         forceWebView: false,
            //       );
            //     } else {
            //       throw 'Could not launch';
            //     }
            //   },
            //   child: ListTile(
            //     leading: CircleAvatar(
            //       child: Icon(LineIcons.bug),
            //     ),
            //     title: Text('Report Bug'),
            //     subtitle: Text('Found a bug? Report here.'),
            //   ),
            // ),
            InkWell(
              borderRadius: BorderRadius.circular(15.0),
              onTap: () async {
                if (await canLaunch(
                    'https://paypal.me/AhmadHammamMH?country.x=ID&locale.x=id_ID')) {
                  await launch(
                    'https://paypal.me/AhmadHammamMH?country.x=ID&locale.x=id_ID',
                    forceSafariVC: false,
                    forceWebView: false,
                  );
                } else {
                  throw 'Could not launch';
                }
              },
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(LineIcons.donate),
                ),
                title: Text('Donate us!'),
                subtitle: Text('using PayPal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
