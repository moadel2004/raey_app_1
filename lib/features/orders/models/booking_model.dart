import '../../../core/constants/app_strings.dart';

class BookingVet {
  const BookingVet({required this.vetId, required this.fullName});
  final int vetId;
  final String fullName;

  factory BookingVet.fromJson(Map<String, dynamic> j) => BookingVet(
        vetId:    (j['vetId'] as num?)?.toInt() ?? 0,
        fullName: j['fullName'] as String? ?? '',
      );
}

class BookingFarm {
  const BookingFarm({
    required this.farmId,
    required this.name,
    required this.location,
    required this.region,
  });
  final int farmId;
  final String name;
  final String location;
  final String region;

  factory BookingFarm.fromJson(Map<String, dynamic> j) => BookingFarm(
        farmId:   (j['farmId'] as num?)?.toInt() ?? 0,
        name:     j['name']     as String? ?? '',
        location: j['location'] as String? ?? '',
        region:   j['region']   as String? ?? '',
      );
}

class BookingAnimal {
  const BookingAnimal({
    required this.animalId,
    required this.type,
    required this.breed,
  });
  final int animalId;
  final String type;
  final String breed;

  factory BookingAnimal.fromJson(Map<String, dynamic> j) => BookingAnimal(
        animalId: (j['animalId'] as num?)?.toInt() ?? 0,
        type:     j['type']  as String? ?? '',
        breed:    j['breed'] as String? ?? '',
      );
}

class BookingModel {
  const BookingModel({
    required this.bookingId,
    required this.type,
    required this.scheduledAt,
    required this.status,
    required this.veterinarian,
    this.farm,
    required this.animals,
  });

  final int bookingId;
  final String type;
  final DateTime scheduledAt;
  final String status;
  final BookingVet veterinarian;
  final BookingFarm? farm;
  final List<BookingAnimal> animals;

  String get statusAr {
    switch (status) {
      case 'Pending':   return AppStrings.bookingStatusPending;
      case 'Confirmed': return AppStrings.bookingStatusConfirmed;
      case 'Completed': return AppStrings.bookingStatusCompleted;
      case 'Cancelled': return AppStrings.bookingStatusCancelled;
      default:          return status;
    }
  }

  String get typeAr {
    switch (type) {
      case 'FarmVisit': return AppStrings.bookingTypeFarmVisit;
      case 'Online':    return AppStrings.bookingTypeOnline;
      default:          return type;
    }
  }

  // حالة الحجز → لون مناسب للعرض
  bool get isPending   => status == 'Pending';
  bool get isConfirmed => status == 'Confirmed';
  bool get isCompleted => status == 'Completed';
  bool get isCancelled => status == 'Cancelled';

  factory BookingModel.fromJson(Map<String, dynamic> j) {
    final vetMap  = j['veterinarian'] as Map<String, dynamic>?;
    final farmMap = j['farm']         as Map<String, dynamic>?;
    final animalList = (j['animals'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(BookingAnimal.fromJson)
        .toList();

    return BookingModel(
      bookingId:    (j['bookingId'] as num?)?.toInt() ?? 0,
      type:         j['type']   as String? ?? '',
      scheduledAt:  DateTime.tryParse(j['scheduledAt'] as String? ?? '') ?? DateTime.now(),
      status:       j['status'] as String? ?? '',
      veterinarian: vetMap  != null ? BookingVet.fromJson(vetMap)   : const BookingVet(vetId: 0, fullName: ''),
      farm:         farmMap != null ? BookingFarm.fromJson(farmMap) : null,
      animals:      animalList,
    );
  }
}
