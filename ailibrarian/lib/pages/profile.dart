import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF909590),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 100),
              Container(
                padding: const EdgeInsets.all(16.0).copyWith(bottom: 0),
                width: double.infinity, // Match parent width
                // height: 200,
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Align(widthFactor: 0.95, child: profilepfp()),
                            Align(
                              widthFactor: 0.85,
                              alignment: Alignment.center,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Color(0xFF2C302E),
                                ),
                                width: 225,
                                // height: 50,
                                child: username(context),
                              ),
                            ),
                          ]),
                    ),
                    SizedBox(height: 30),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Color(0xFF2C302E),
                      ),
                      width: 400,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Color(0xFF537A5A),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                genregrid(),
                              ],
                            ),
                          ),
                          // profiledivider(),
                          SizedBox(height: 20),
                          // profiledivider(),
                          Text(
                            'About ',
                            style: TextStyle(color: Colors.white, fontSize: 19),
                          ),
                          profiledivider(),
                          SizedBox(height: 20),
                          Text(
                            '''Hi, I’m Leonard Hofstadter, an experimental physicist with a Ph.D. from Princeton University. I work at Caltech, where I delve into exciting research on lasers and quantum mechanics.When I’m not in the lab, I enjoy comic books, Star Wars marathons, and awkward yet endearing attempts at social interaction. My life is a mix of physics equations, nerdy debates, and trying to make sense of relationships—and I wouldn't have it any other way.''',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          )
                        ],
                      ),
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

  Padding username(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Text('Leonard Hofstadter',
          style: TextStyle(
              color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800),
          textAlign: TextAlign.center),
    );
  }
}

class profiledivider extends StatelessWidget {
  const profiledivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      child: Divider(
        color: Colors.white,
        thickness: 1,
        height: 10,
      ),
    );
  }
}

class genregrid extends StatelessWidget {
  const genregrid({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<String> genres = ['Fiction', 'Comics', 'Manga'];
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 3.5,
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color(0xFF2C302E),
        ),
        child: Center(
          child: Text(
            genres[index],
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ),
      itemCount: 3,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    );
  }
}

class profilepfp extends StatelessWidget {
  const profilepfp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(-8.5, 0),
      child: CircleAvatar(
        backgroundColor: Color(0xFF2C302E),
        radius: 122 / 2 + 10,
        child: CircleAvatar(
          radius: 122 / 2,
          backgroundImage: NetworkImage(
              'https://scontent.fccu31-2.fna.fbcdn.net/v/t39.30808-6/309392050_526802052780674_8359549980210538240_n.jpg?_nc_cat=109&ccb=1-7&_nc_sid=6ee11a&_nc_ohc=9xZvf6XXHHcQ7kNvgHoLWGT&_nc_zt=23&_nc_ht=scontent.fccu31-2.fna&_nc_gid=ATmOB9uWlc89SWiJ4nfzadj&oh=00_AYCYr89mgfYR22X2cm-wTEUGNG3zkZ_kRD7zdyvhXcKarA&oe=677EBA5B'),
        ),
      ),
    );
  }
}
