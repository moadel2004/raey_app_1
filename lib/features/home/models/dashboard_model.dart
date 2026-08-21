import '../../../core/constants/app_strings.dart';
import '../../animals/models/animal_model.dart';
import '../../farms/models/farm_model.dart';

/// Booking entry as returned by GET /dashboard (simpler than BookingResponseDto)
class BookingSummaryModel {
  const BookingSummaryModel({
    required this.id,
    required this.scheduledAt,
    required this.status,
    required this.type,
    required this.veterinarianName,
    required this.farmName,
    required this.animalCount,
  });

  final int id;
  final DateTime scheduledAt;
  final String status;
  final String type;
  final String veterinarianName;
  final String farmName;
  final int animalCount;

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

  bool get isPending   => status == 'Pending';
  bool get isConfirmed => status == 'Confirmed';

  factory BookingSummaryModel.fromJson(Map<String, dynamic> j) =>
      BookingSummaryModel(
        id:               (j['id'] as num?)?.toInt() ?? 0,
        scheduledAt:      DateTime.tryParse(j['scheduledAt'] as String? ?? '') ??
                          DateTime.now(),
        status:           j['status']           as String? ?? '',
        type:             j['type']             as String? ?? '',
        veterinarianName: j['veterinarianName'] as String? ?? '',
        farmName:         j['farmName']         as String? ?? '',
        animalCount:      (j['animalCount'] as num?)?.toInt() ?? 0,
      );
}

/// Single entry from recentMedicalRecords
class MedicalRecordSummaryModel {
  const MedicalRecordSummaryModel({
    required this.id,
    required this.createdAt,
    required this.visitType,
    required this.animalTagId,
    required this.animalType,
    required this.veterinarianName,
    required this.diagnosis,
  });

  final int id;
  final DateTime createdAt;
  final String visitType;
  final String animalTagId;
  final String animalType;
  final String veterinarianName;
  final String diagnosis;

  factory MedicalRecordSummaryModel.fromJson(Map<String, dynamic> j) =>
      MedicalRecordSummaryModel(
        id:               (j['id'] as num?)?.toInt() ?? 0,
        createdAt:        DateTime.tryParse(j['createdAt'] as String? ?? '') ??
                          DateTime.now(),
        visitType:        j['visitType']        as String? ?? '',
        animalTagId:      j['animalTagId']      as String? ?? '',
        animalType:       j['animalType']       as String? ?? '',
        veterinarianName: j['veterinarianName'] as String? ?? '',
        diagnosis:        j['diagnosis']        as String? ?? '',
      );
}

/// Top-level dashboard response for GET /dashboard (Farmer only)
class DashboardModel {
  const DashboardModel({
    required this.totalAnimals,
    required this.totalBookings,
    required this.totalFarms,
    required this.pendingBookings,
    required this.completedBookings,
    required this.cancelledBookings,
    required this.upcomingBookings,
    required this.recentMedicalRecords,
    required this.animals,
    required this.farms,
  });

  final int totalAnimals;
  final int totalBookings;
  final int totalFarms;
  final int pendingBookings;
  final int completedBookings;
  final int cancelledBookings;
  final List<BookingSummaryModel> upcomingBookings;
  final List<MedicalRecordSummaryModel> recentMedicalRecords;
  final List<AnimalModel> animals;
  final List<FarmModel> farms;

  factory DashboardModel.fromJson(Map<String, dynamic> j) => DashboardModel(
        totalAnimals:      (j['totalAnimals']      as num?)?.toInt() ?? 0,
        totalBookings:     (j['totalBookings']     as num?)?.toInt() ?? 0,
        totalFarms:        (j['totalFarms']        as num?)?.toInt() ?? 0,
        pendingBookings:   (j['pendingBookings']   as num?)?.toInt() ?? 0,
        completedBookings: (j['completedBookings'] as num?)?.toInt() ?? 0,
        cancelledBookings: (j['cancelledBookings'] as num?)?.toInt() ?? 0,
        upcomingBookings: (j['upcomingBookings'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(BookingSummaryModel.fromJson)
            .toList(),
        recentMedicalRecords: (j['recentMedicalRecords'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(MedicalRecordSummaryModel.fromJson)
            .toList(),
        animals: (j['animals'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(AnimalModel.fromJson)
            .toList(),
        farms: (j['farms'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(FarmModel.fromJson)
            .toList(),
      );
}
