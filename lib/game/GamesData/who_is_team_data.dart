
class Player {
  final String name;
  final List<String> acceptableAnswers;
  bool isGuessed;

  Player({
    required this.name,
    required this.acceptableAnswers,
    this.isGuessed = false,
  });
}

class Team {
  final String name;
  final String teamImage;
  final List<Player> players;

  Team({
    required this.name,
    required this.teamImage,
    required this.players,
  });
}

class Game3Data {
  static final List<Team> teams = [
    Team(
      name: "برشلونة 2009",
      teamImage: "assets/teams/barca2009.jpg",
      players: [
        Player(name: "فيكتور فالديز", acceptableAnswers: ["فالديز", "فيكتور فالديز"]),
        Player(name: "كارليس بويول", acceptableAnswers: ["بويول", "كارليس بويول"]),
        Player(name: "جيرارد بيكيه", acceptableAnswers: ["بيكيه", "جيرارد بيكيه"]),
        Player(name: "سيدو كيتا", acceptableAnswers: ["كيتا", "سيدو كيتا"]),
        Player(name: "تشافي هيرنانديز", acceptableAnswers: ["تشافي", "تشافي هيرنانديز"]),
        Player(name: "أندريس إنييستا", acceptableAnswers: ["إنييستا", "أندريس إنييستا"]),
        Player(name: "تيري هنري", acceptableAnswers: ["هنري", "تيري هنري"]),
        Player(name: "ليونيل ميسي", acceptableAnswers: ["ميسي", "ليونيل ميسي"]),
        Player(name: "سامويل إيتو", acceptableAnswers: ["إيتو", "سامويل إيتو"]),
        Player(name: "داني ألفيس", acceptableAnswers: ["ألفيس", "داني ألفيس"]),
        Player(name: "رافائيل ماركيز", acceptableAnswers: ["ماركيز", "رافائيل ماركيز"]),
      ],
    ),
  
  
  Team(
  name: "ريال مدريد 2017",
  teamImage: "assets/teams/madred2017.jpg",
  players: [
    Player(
      name: "كيلور نافاس",
      acceptableAnswers: ["نافاس", "كيلور نافاس"],
    ),
    Player(
      name: "سيرخيو راموس",
      acceptableAnswers: ["راموس", "سيرخيو راموس"],
    ),
    Player(
      name: "مارسيلو فييرا",
      acceptableAnswers: ["مارسيلو", "مارسيلو فييرا"],
    ),
    Player(
      name: "داني كارفاخال",
      acceptableAnswers: ["كارفاخال", "داني كارفاخال"],
    ),
    Player(
      name: "كاسيميرو",
      acceptableAnswers: ["كاسيميرو"],
    ),
    Player(
      name: "لوكا مودريتش",
      acceptableAnswers: ["مودريتش", "لوكا مودريتش"],
    ),
    Player(
      name: "كريستيانو رونالدو",
      acceptableAnswers: ["رونالدو", "كريستيانو رونالدو"],
    ),
    Player(
      name: "إيسكو ألاركون",
      acceptableAnswers: ["إيسكو", "إيسكو ألاركون"],
    ),
    Player(
      name: "غاريث بيل",
      acceptableAnswers: ["بيل", "غاريث بيل"],
    ),
    Player(
      name: "ناتشو فيرنانديز",
      acceptableAnswers: ["ناتشو", "ناتشو فيرنانديز"],
    ),
    Player(
      name: "ماتيو كوفاسيتش",
      acceptableAnswers: ["كوفاسيتش", "ماتيو كوفاسيتش"],
    ),
  ],
),

Team(
  name: "برشلونة 2011",
  teamImage: "assets/teams/barca2011.jpeg",
  players: [
    Player(
      name: "فيكتور فالديز",
      acceptableAnswers: ["فالديز", "فيكتور فالديز"],
    ),
    Player(
      name: "داني ألفيس",
      acceptableAnswers: ["ألفيس", "داني ألفيس"],
    ),
    Player(
      name: "جيرارد بيكيه",
      acceptableAnswers: ["بيكيه", "جيرارد بيكيه"],
    ),
    Player(
      name: "كارليس بويول",
      acceptableAnswers: ["بويول", "كارليس بويول"],
    ),
    Player(
      name: "إريك أبيدال",
      acceptableAnswers: ["أبيدال", "إريك أبيدال"],
    ),
    Player(
      name: "سيرجيو بوسكيتس",
      acceptableAnswers: ["بوسكيتس", "سيرجيو بوسكيتس"],
    ),
    Player(
      name: "تشافي هيرنانديز",
      acceptableAnswers: ["تشافي", "تشافي هيرنانديز"],
    ),
    Player(
      name: "أندريس إنييستا",
      acceptableAnswers: ["إنييستا", "أندريس إنييستا"],
    ),
    Player(
      name: "بيدرو رودريغيز",
      acceptableAnswers: ["بيدرو", "بيدرو رودريغيز"],
    ),
    Player(
      name: "دافيد فيا",
      acceptableAnswers: ["فيا", "دافيد فيا"],
    ),
    Player(
      name: "ليونيل ميسي",
      acceptableAnswers: ["ميسي", "ليونيل ميسي"],
    ),
  ],
),
Team(
  name: "بايرن ميونيخ 2020",
  teamImage: "assets/teams/bayern2020.jpg",
  players: [
    Player(
      name: "مانويل نوير",
      acceptableAnswers: ["نوير", "مانويل نوير"],
    ),
    Player(
      name: "ديفيد ألابا",
      acceptableAnswers: ["ألابا", "ديفيد ألابا"],
    ),
    Player(
      name: "جيروم بواتينج",
      acceptableAnswers: ["بواتينج", "جيروم بواتينج"],
    ),
    Player(
      name: "ليون غوريتسكا",
      acceptableAnswers: ["غوريتسكا", "ليون غوريتسكا"],
    ),
    Player(
      name: "جوشوا كيميش",
      acceptableAnswers: ["كيميش", "جوشوا كيميش"],
    ),
    Player(
      name: "ألفونسو ديفيز",
      acceptableAnswers: ["ديفيز", "ألفونسو ديفيز"],
    ),
    Player(
      name: "تياغو ألكانتارا",
      acceptableAnswers: ["تياغو", "تياغو ألكانتارا"],
    ),
    Player(
      name: "توماس مولر",
      acceptableAnswers: ["مولر", "توماس مولر"],
    ),
    Player(
      name: "سيرج غنابري",
      acceptableAnswers: ["غنابري", "سيرج غنابري"],
    ),
    Player(
      name: "روبرت ليفاندوفسكي",
      acceptableAnswers: ["ليفاندوفسكي", "روبرت ليفاندوفسكي"],
    ),
    Player(
      name: "بيريستش",
      acceptableAnswers: [ "بيريستش"],
    ),
  ],
),
Team(
  name: "إسبانيا 2010",
  teamImage: "assets/teams/Spain2010.jpg",
  players: [
    Player(
      name: "إيكر كاسياس",
      acceptableAnswers: ["كاسياس", "إيكر كاسياس"],
    ),
    Player(
      name: "جيرارد بيكيه",
      acceptableAnswers: ["بيكيه", "جيرارد بيكيه"],
    ),
    Player(
      name: "كارليس بويول",
      acceptableAnswers: ["بويول", "كارليس بويول"],
    ),
    Player(
      name: "سيرجيو راموس",
      acceptableAnswers: ["راموس", "سيرجيو راموس"],
    ),
    Player(
      name: "جوان كابديفيلا",
      acceptableAnswers: ["كابديفيلا", "جوان كابديفيلا"],
    ),
    Player(
      name: "سيرجيو بوسكيتس",
      acceptableAnswers: ["بوسكيتس", "سيرجيو بوسكيتس"],
    ),
    Player(
      name: "تشافي هيرنانديز",
      acceptableAnswers: ["تشافي", "تشافي هيرنانديز"],
    ),
    Player(
      name: "أندريس إنييستا",
      acceptableAnswers: ["إنييستا", "أندريس إنييستا"],
    ),
    Player(
      name: "تشابي ألونسو",
      acceptableAnswers: ["ألونسو", "تشابي ألونسو"],
    ),
    Player(
      name: "دافيد فيا",
      acceptableAnswers: ["فيا", "دافيد فيا"],
    ),
    Player(
      name: "بيدرو رودريغيز",
      acceptableAnswers: ["بيدرو", "بيدرو رودريغيز"],
    ),
  ],
),
Team(
  name: "مانشستر سيتي 2023",
  teamImage: "assets/teams/man_city2023.jpeg",
  players: [
    Player(
      name: "إيدرسون مورايس",
      acceptableAnswers: ["إيدرسون", "إيدرسون مورايس"],
    ),
    Player(
      name: "روبن دياز",
      acceptableAnswers: ["روبن دياز", "دياز"],
    ),
    Player(
      name: "جون ستونز",
      acceptableAnswers: ["ستونز", "جون ستونز"],
    ),
    Player(
      name: "مانويل أكانجي",
      acceptableAnswers: ["أكانجي", "مانويل أكانجي"],
    ),
    Player(
      name: "رودري هيرنانديز",
      acceptableAnswers: ["رودري", "رودري هيرنانديز"],
    ),
    Player(
      name: "إلكاي غوندوغان",
      acceptableAnswers: ["غوندوغان", "إلكاي غوندوغان"],
    ),
    Player(
      name: "برناردو سيلفا",
      acceptableAnswers: ["سيلفا", "برناردو سيلفا"],
    ),
    Player(
      name: "جاك غريليش",
      acceptableAnswers: ["غريليش", "جاك غريليش"],
    ),
    Player(
      name: "كيفين دي بروين",
      acceptableAnswers: ["دي بروين", "كيفين دي بروين"],
    ),
    Player(
      name: "إيرلينغ هالاند",
      acceptableAnswers: ["هالاند", "إيرلينغ هالاند"],
    ),
    Player(
      name: "ناثان اكي",
      acceptableAnswers: ["اكي", "ناثان اكي"],
    ),
  ],
),

Team(
  name: "مانشستر يونايتد 2008",
  teamImage: "assets/teams/man_united2008.jpg",
  players: [
    Player(
      name: "إدوين فان دير سار",
      acceptableAnswers: ["فان دير سار", "إدوين فان دير سار"],
    ),
    Player(
      name: "نيمانيا فيديتش",
      acceptableAnswers: ["فيديتش", "نيمانيا فيديتش"],
    ),
    Player(
      name: "ريو فرديناند",
      acceptableAnswers: ["فرديناند", "ريو فرديناند"],
    ),
    Player(
      name: "ويس براون",
      acceptableAnswers: ["براون", "ويس براون"],
    ),
    Player(
      name: "باتريس إيفرا",
      acceptableAnswers: ["إيفرا", "باتريس إيفرا"],
    ),
    Player(
      name: "كريستيانو رونالدو",
      acceptableAnswers: ["رونالدو", "كريستيانو رونالدو"],
    ),
    Player(
      name: "بول سكولز",
      acceptableAnswers: ["سكولز", "بول سكولز"],
    ),
    Player(
      name: "مايكل كاريك",
      acceptableAnswers: ["كاريك", "مايكل كاريك"],
    ),
    Player(
      name: "أوين هارجريفز",
      acceptableAnswers: ["هارجريفز", "أوين هارجريفز"],
    ),
    Player(
      name: "واين روني",
      acceptableAnswers: ["روني", "واين روني"],
    ),
    Player(
      name: "كارلوس تيفيز",
      acceptableAnswers: ["تيفيز", "كارلوس تيفيز"],
    ),
  ],
),
  ];
}



