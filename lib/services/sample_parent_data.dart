/// Parent data model for sample data
class ParentModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final List<String> childrenIds;
  final String? emergencyContact;
  final String? emergencyPhone;
  final String? occupation;

  ParentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.childrenIds,
    this.emergencyContact,
    this.emergencyPhone,
    this.occupation,
  });

  /// Convert to JSON-like map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'childrenIds': childrenIds,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'occupation': occupation,
    };
  }
}

class SampleParentData {
  /// Generate all sample parents (11 total)
  static List<ParentModel> generateSampleParents() {
    return [
      // p1 - 1 child (s4)
      ParentModel(
        id: 'p1',
        name: 'Abdullah Hassan',
        email: 'abdullah.hassan@email.com',
        phone: '+60 12-345 6789',
        address: '123 Jalan Merdeka, Kuala Lumpur, 50050',
        childrenIds: ['s4'],
        emergencyContact: 'Siti Hassan',
        emergencyPhone: '+60 12-345 6790',
        occupation: 'Software Engineer',
      ),

      // p2 - 1 child (s1)
      ParentModel(
        id: 'p2',
        name: 'Encik Karim Ahmad',
        email: 'karim.ahmad@email.com',
        phone: '+60 19-876 5432',
        address: '456 Jalan Sultan Ismail, Kuala Lumpur, 50250',
        childrenIds: ['s1'],
        emergencyContact: 'Fatimah Karim',
        emergencyPhone: '+60 19-876 5433',
        occupation: 'Business Manager',
      ),

      // p3 - 1 child (s2)
      ParentModel(
        id: 'p3',
        name: 'Puan Norhaida Mahmud',
        email: 'norhaida.mahmud@email.com',
        phone: '+60 17-234 5678',
        address: '789 Jalan Tun Razak, Kuala Lumpur, 50400',
        childrenIds: ['s2'],
        emergencyContact: 'Ahmad Mahmud',
        emergencyPhone: '+60 17-234 5679',
        occupation: 'School Administrator',
      ),

      // p4 - 1 child (s5)
      ParentModel(
        id: 'p4',
        name: 'Encik Lim Chen Hao',
        email: 'lim.chenhao@email.com',
        phone: '+60 16-789 4561',
        address: '321 Persiaran Kuala Lumpur, Kuala Lumpur, 50088',
        childrenIds: ['s5'],
        emergencyContact: 'Lim Wei Ling',
        emergencyPhone: '+60 16-789 4562',
        occupation: 'Accountant',
      ),

      // p5 - 1 child (s6)
      ParentModel(
        id: 'p5',
        name: 'Mr. Raj Nair Kumar',
        email: 'raj.kumar@email.com',
        phone: '+60 11-555 8888',
        address: '654 Jalan Raja Chulan, Kuala Lumpur, 50200',
        childrenIds: ['s6'],
        emergencyContact: 'Priya Kumar',
        emergencyPhone: '+60 11-555 8889',
        occupation: 'Marketing Executive',
      ),

      // p6 - 1 child (s7)
      ParentModel(
        id: 'p6',
        name: 'Encik Wong Tian Huat',
        email: 'wong.tianhuat@email.com',
        phone: '+60 18-912 3456',
        address: '987 Jalan Bukit Bintang, Kuala Lumpur, 55100',
        childrenIds: ['s7'],
        emergencyContact: 'Wong Mei Ling',
        emergencyPhone: '+60 18-912 3457',
        occupation: 'Import/Export Trader',
      ),

      // p7 - 1 child (s8)
      ParentModel(
        id: 'p7',
        name: 'Mr. Viswanathan Sharma',
        email: 'viswanathan.sharma@email.com',
        phone: '+60 12-678 9012',
        address: '159 Jalan Damansara, Kuala Lumpur, 50490',
        childrenIds: ['s8'],
        emergencyContact: 'Lakshmi Sharma',
        emergencyPhone: '+60 12-678 9013',
        occupation: 'Consultant',
      ),

      // p8 - 2 children (s3, s11) ⭐ SPECIAL CASE
      ParentModel(
        id: 'p8',
        name: 'Puan Siti Nur Azizah',
        email: 'siti.azizah@email.com',
        phone: '+60 13-234 5678',
        address: '246 Jalan Ampang, Kuala Lumpur, 68000',
        childrenIds: ['s3', 's11'],
        emergencyContact: 'Ahmad Yusof',
        emergencyPhone: '+60 13-234 5679',
        occupation: 'Nurse',
      ),

      // p9 - 1 child (s12)
      ParentModel(
        id: 'p9',
        name: 'Encik Ooi Seng Keat',
        email: 'ooi.sengkeat@email.com',
        phone: '+60 14-567 8901',
        address: '753 Jalan Sultan Ahmad Shah, Kuala Lumpur, 50100',
        childrenIds: ['s12'],
        emergencyContact: 'Ooi Mei Hua',
        emergencyPhone: '+60 14-567 8902',
        occupation: 'Purchasing Officer',
      ),

      // p10 - 1 child (s10)
      ParentModel(
        id: 'p10',
        name: 'Encik Tan Cheng Huat',
        email: 'tan.chenghuat@email.com',
        phone: '+60 15-890 1234',
        address: '852 Jalan Pudu, Kuala Lumpur, 55100',
        childrenIds: ['s10'],
        emergencyContact: 'Tan Ah Kian',
        emergencyPhone: '+60 15-890 1235',
        occupation: 'Factory Manager',
      ),

      // p11 - 1 child (s9)
      ParentModel(
        id: 'p11',
        name: 'Encik Rashid Abdullah',
        email: 'rashid.abdullah@email.com',
        phone: '+60 19-123 4567',
        address: '357 Jalan Raja Laut, Kuala Lumpur, 50350',
        childrenIds: ['s9'],
        emergencyContact: 'Aminah Rashid',
        emergencyPhone: '+60 19-123 4568',
        occupation: 'Teacher',
      ),
    ];
  }

  /// Get a specific parent by ID
  static ParentModel? getSampleParentById(String parentId) {
    try {
      return generateSampleParents().firstWhere((parent) => parent.id == parentId);
    } catch (e) {
      return null;
    }
  }

  /// Get all children IDs for a parent
  static List<String> getChildrenForParent(String parentId) {
    final parent = getSampleParentById(parentId);
    return parent?.childrenIds ?? [];
  }

  /// Get parent details for a specific child
  static ParentModel? getParentForChild(String childId) {
    try {
      return generateSampleParents()
          .firstWhere((parent) => parent.childrenIds.contains(childId));
    } catch (e) {
      return null;
    }
  }

  /// Search parents by name or email
  static List<ParentModel> searchParents(String keyword) {
    final all = generateSampleParents();
    final lowerKeyword = keyword.toLowerCase();

    return all
        .where((parent) =>
            parent.name.toLowerCase().contains(lowerKeyword) ||
            parent.email.toLowerCase().contains(lowerKeyword) ||
            parent.phone.contains(keyword))
        .toList();
  }

  /// Get all parents (for admin/teacher view)
  static List<ParentModel> getAllParents() {
    return generateSampleParents();
  }

  /// Get parent count
  static int getParentCount() {
    return generateSampleParents().length;
  }

  /// Get parents by number of children (useful for special handling)
  static List<ParentModel> getParentsByChildCount(int childCount) {
    final all = generateSampleParents();
    return all.where((parent) => parent.childrenIds.length == childCount).toList();
  }

  /// Get all parents with multiple children (special cases)
  static List<ParentModel> getMultiChildParents() {
    final all = generateSampleParents();
    return all.where((parent) => parent.childrenIds.length > 1).toList();
  }

  /// Get contact info summary
  static String getContactSummary(String parentId) {
    final parent = getSampleParentById(parentId);
    if (parent == null) return 'Parent not found';

    return '''Name: ${parent.name}
Email: ${parent.email}
Phone: ${parent.phone}
Address: ${parent.address}
Children: ${parent.childrenIds.length}${parent.childrenIds.length > 1 ? ' (${parent.childrenIds.join(', ')})' : ''}
Occupation: ${parent.occupation ?? 'Not specified'}
Emergency Contact: ${parent.emergencyContact ?? 'Not specified'} (${parent.emergencyPhone ?? 'N/A'})''';
  }

  /// Update parent info (mock - returns new instance)
  static ParentModel updateParentMock(
    String parentId,
    Map<String, dynamic> updates,
  ) {
    final parent = getSampleParentById(parentId);
    if (parent == null) throw Exception('Parent not found');

    return ParentModel(
      id: parent.id,
      name: updates['name'] ?? parent.name,
      email: updates['email'] ?? parent.email,
      phone: updates['phone'] ?? parent.phone,
      address: updates['address'] ?? parent.address,
      childrenIds: updates['childrenIds'] ?? parent.childrenIds,
      emergencyContact: updates['emergencyContact'] ?? parent.emergencyContact,
      emergencyPhone: updates['emergencyPhone'] ?? parent.emergencyPhone,
      occupation: updates['occupation'] ?? parent.occupation,
    );
  }

  /// Verify parent-child relationship
  static bool isChildOfParent(String childId, String parentId) {
    final parent = getSampleParentById(parentId);
    return parent?.childrenIds.contains(childId) ?? false;
  }

  /// Get parent details display (formatted for UI)
  static Map<String, dynamic> getFormattedParentInfo(String parentId) {
    final parent = getSampleParentById(parentId);
    if (parent == null) return {};

    return {
      'name': parent.name,
      'email': parent.email,
      'phone': parent.phone,
      'address': parent.address,
      'childCount': parent.childrenIds.length,
      'children': parent.childrenIds,
      'occupation': parent.occupation ?? 'Not specified',
      'emergencyContact': {
        'name': parent.emergencyContact ?? 'Not specified',
        'phone': parent.emergencyPhone ?? 'Not specified',
      },
    };
  }
}
