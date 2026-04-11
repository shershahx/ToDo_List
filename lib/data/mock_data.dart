import '../models/user.dart';
import '../models/post.dart';


class MockData {
  static List<User> get users => [
    User(
      id: 1,
      name: 'Ali Hassan',
      username: 'ali.hassan',
      email: 'ali.hassan@techpk.com',
      phone: '+92-300-1234567',
      website: 'alihassan.pk',
      address: Address(city: 'Karachi'),
      company: Company(name: 'TechPK Solutions'),
    ),
    User(
      id: 2,
      name: 'Fatima Malik',
      username: 'fatima.malik',
      email: 'fatima@nextventures.pk',
      phone: '+92-321-9876543',
      website: 'fatima.dev',
      address: Address(city: 'Lahore'),
      company: Company(name: 'NextVentures Pakistan'),
    ),
    User(
      id: 3,
      name: 'Usman Akhtar',
      username: 'uakhtar',
      email: 'usman.akhtar@sistemspk.com',
      phone: '+92-333-5556789',
      website: 'sistemspk.com',
      address: Address(city: 'Islamabad'),
      company: Company(name: 'Sistems Pakistan'),
    ),
    User(
      id: 4,
      name: 'Ayesha Siddiqui',
      username: 'ayeshasid',
      email: 'ayesha@crescentsoft.io',
      phone: '+92-311-4447890',
      website: 'crescentsoft.io',
      address: Address(city: 'Rawalpindi'),
      company: Company(name: 'Crescent Soft'),
    ),
    User(
      id: 5,
      name: 'Bilal Chaudhry',
      username: 'bilalc',
      email: 'bilal.chaudhry@iqra.edu.pk',
      phone: '+92-345-2223456',
      website: 'iqra.edu.pk',
      address: Address(city: 'Karachi'),
      company: Company(name: 'Iqra University'),
    ),
    User(
      id: 6,
      name: 'Sana Qureshi',
      username: 'sanaq',
      email: 'sana.qureshi@paysys.pk',
      phone: '+92-312-8889012',
      website: 'paysys.pk',
      address: Address(city: 'Lahore'),
      company: Company(name: 'PaySys Technologies'),
    ),
    User(
      id: 7,
      name: 'Hamza Tariq',
      username: 'hamzat92',
      email: 'hamza.tariq@infotech.com.pk',
      phone: '+92-301-7778901',
      website: 'infotech.com.pk',
      address: Address(city: 'Faisalabad'),
      company: Company(name: 'InfoTech Pvt. Ltd.'),
    ),
    User(
      id: 8,
      name: 'Zainab Raza',
      username: 'zainab.raza',
      email: 'zainab@skynet.pk',
      phone: '+92-322-6667890',
      website: 'skynet.pk',
      address: Address(city: 'Multan'),
      company: Company(name: 'SkyNet Digital'),
    ),
    User(
      id: 9,
      name: 'Omar Farooq',
      username: 'ofarooq',
      email: 'omar.farooq@netsol.com',
      phone: '+92-315-1112345',
      website: 'netsol.com',
      address: Address(city: 'Lahore'),
      company: Company(name: 'NetSol Technologies'),
    ),
    User(
      id: 10,
      name: 'Hira Baig',
      username: 'hira.baig',
      email: 'hira.baig@arpatech.com',
      phone: '+92-303-4445678',
      website: 'arpatech.com',
      address: Address(city: 'Karachi'),
      company: Company(name: 'Arpatech Pvt. Ltd.'),
    ),
  ];

  static Map<int, List<Post>> get postsByUser => {
    1: [
      Post(id: 1, userId: 1, title: 'Flutter app development best practices', body: 'In this post I share the best practices I have learned building Flutter apps for Pakistani startups over the past two years, from state management to localization.'),
      Post(id: 2, userId: 1, title: 'REST API integration with Flutter', body: 'A step-by-step guide to integrating RESTful APIs in Flutter using the http package, with proper error handling and loading states.'),
    ],
    2: [
      Post(id: 3, userId: 2, title: 'Women in tech — my journey in Pakistan', body: 'Sharing my experience as a female software engineer in Pakistan, the challenges I faced and the opportunities that came my way.'),
      Post(id: 4, userId: 2, title: 'Building scalable backends with Node.js', body: 'How we scaled our startup backend from 100 to 10,000 daily active users using Node.js, Redis, and PostgreSQL.'),
    ],
    3: [
      Post(id: 5, userId: 3, title: 'DevOps practices for small teams', body: 'At Sistems Pakistan we run a lean DevOps pipeline with GitHub Actions and Docker that any small team can adopt.'),
    ],
    4: [
      Post(id: 6, userId: 4, title: 'UI/UX design lessons from Pakistani users', body: 'Pakistani mobile users have distinct UX expectations. Here are five key insights from our usability testing sessions in Rawalpindi.'),
    ],
    5: [
      Post(id: 7, userId: 5, title: 'Teaching programming in Urdu', body: 'Why localized programming education matters and what we learned from our pilot Urdu coding bootcamp at Iqra University.'),
      Post(id: 8, userId: 5, title: 'Open source contributions from Pakistan', body: 'A roundup of amazing open-source projects by Pakistani developers that deserve more attention from the global community.'),
    ],
    6: [
      Post(id: 9, userId: 6, title: 'Fintech regulation in Pakistan — 2025 update', body: 'SBP has introduced new digital payment guidelines. Here is what they mean for fintech startups like ours.'),
    ],
    7: [
      Post(id: 10, userId: 7, title: 'Machine learning for Punjabi NLP', body: 'Our research at InfoTech into building NLP models for Punjabi and Urdu text — datasets, challenges, and early results.'),
    ],
    8: [
      Post(id: 11, userId: 8, title: 'Remote work culture in Pakistani startups', body: 'SkyNet went fully remote in 2023. Here is what worked, what did not, and how we maintain team culture across cities.'),
    ],
    9: [
      Post(id: 12, userId: 9, title: 'NetSol at 25 — lessons from a Pakistani tech giant', body: 'Reflecting on 25 years of NetSol Technologies and the lessons the next generation of Pakistani tech entrepreneurs can learn from our journey.'),
      Post(id: 13, userId: 9, title: 'ERP for the agriculture sector', body: 'How we adapted our enterprise software products to serve Pakistan\'s agriculture sector, from farm management to supply chain.'),
    ],
    10: [
      Post(id: 14, userId: 10, title: 'Cybersecurity risks for Pakistani SMEs', body: 'Small and medium businesses in Pakistan are increasingly targeted by cyber attacks. Here is how to protect your company on a limited budget.'),
    ],
  };
}
