class PathanamthittaData {
  static const String district = 'Pathanamthitta';

  static const List<String> localBodyTypes = [
    'Municipality',
    'Grama Panchayat',
  ];

  static const List<String> municipalities = [
    'Pathanamthitta',
    'Adoor',
    'Thiruvalla',
    'Pandalam',
  ];

  static const List<String> gramaPanchayats = [
    'Anicadu',
    'Aranmula',
    'Aruvappulam',
    'Ayiroor',
    'Chenneerkkara',
    'Cherukole',
    'Chittar',
    'Elanthoor',
    'Enadimangalam',
    'Erathu',
    'Eraviperoor',
    'Ezhamkulam',
    'Ezhumattoor',
    'Kadampanad',
    'Kadapra',
    'Kalanjoor',
    'Kallooppara',
    'Kaviyoor',
    'Kodumon',
    'Koipuram',
    'Konni',
    'Kottangal',
    'Kottanad',
    'Kozhencherry',
    'Kulanada',
    'Kunnamthanam',
    'Kuttoor',
    'Malayalapuzha',
    'Mallappally',
    'Mallapuzhassery',
    'Mezhuveli',
    'Mylapra',
    'Naranganam',
    'Naranammoozhi',
    'Nedumpuram',
    'Niranam',
    'Omalloor',
    'Pallickal',
    'Pandalam Thekkekara',
    'Peringara',
    'Pramadom',
    'Puramattam',
    'Ranni',
    'Ranni-Angadi',
    'Ranni-Pazhavangadi',
    'Ranni-Perunad',
    'Seethathodu',
    'Thannithodu',
    'Thottapuzhassery',
    'Thumpamon',
    'Vadasserikkara',
    'Vallicode',
    'Vechoochira',
  ];

  static const List<String> departments = [
    'PWD',
    'KSEB',
    'Water',
    'Health',
    'Municipal',
    'Police',
    'Other',
  ];

  static const Map<String, List<String>> departmentSubdivisions = {
    'PWD': [
      'PWD Roads Section, Pathanamthitta',
      'PWD Roads Section, Adoor',
      'PWD Roads Section, Thiruvalla',
      'PWD Roads Section, Ranni',
      'PWD Buildings Section, Pathanamthitta',
      'PWD Bridges Section, Pathanamthitta',
    ],
    'KSEB': [
      'KSEB Electrical Section, Pathanamthitta',
      'KSEB Electrical Section, Adoor',
      'KSEB Electrical Section, Thiruvalla',
      'KSEB Electrical Section, Pandalam',
      'KSEB Electrical Section, Ranni',
      'KSEB Electrical Section, Konni',
    ],
    'Water': [
      'KWA Section Office, Pathanamthitta',
      'KWA Section Office, Adoor',
      'KWA Section Office, Thiruvalla',
      'KWA Section Office, Ranni',
    ],
    'Health': [
      'General Hospital, Pathanamthitta',
      'General Hospital, Adoor',
      'Taluk Hospital, Thiruvalla',
      'Taluk Hospital, Ranni',
      'Taluk Hospital, Konni',
      'DMO Office, Pathanamthitta',
    ],
    'Municipal': [
      'Municipal Office, Pathanamthitta',
      'Municipal Office, Adoor',
      'Municipal Office, Thiruvalla',
      'Municipal Office, Pandalam',
      'Omalloor Grama Panchayat Office',
    ],
    'Police': [
      'Pathanamthitta Police Station',
      'Adoor Police Station',
      'Thiruvalla Police Station',
      'Pandalam Police Station',
      'Ranni Police Station',
      'Konni Police Station',
      'Kozhencherry Police Station',
      'District Police Chief Office',
    ],
    'Other': [
      'District Collectorate, Pathanamthitta',
      'RDO Office, Adoor',
      'RDO Office, Thiruvalla',
    ],
  };

  static List<String> getLocalBodies(String type) {
    if (type == 'Municipality') {
      return municipalities;
    } else if (type == 'Grama Panchayat') {
      return gramaPanchayats;
    }
    return [];
  }
}
