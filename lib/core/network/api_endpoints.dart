class ApiEndpoints {
  ApiEndpoints._();

  // Azure Production
  static const String baseUrl =
      'https://ra2y-api-abdul-aqfvhffvc8bgethy.francecentral-01.azurewebsites.net/api';
  // تطوير محلي (موبايل حقيقي): static const String baseUrl = 'http://192.168.1.11:5110/api';
  // تطوير محلي (إيميوليتور):  static const String baseUrl = 'http://10.0.2.2:5110/api';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // Bookings
  static const String myBookings = '/bookings/my-bookings';
  static const String vetBookings = '/bookings/veterinarian/bookings';
  static const String bookings = '/bookings';
  static String bookingById(int id) => '/bookings/$id';
  static String bookingStatus(int id) => '/bookings/$id/status';

  // Farms
  static const String farms = '/farms';
  static String farmById(int id) => '/farms/$id';

  // Animals
  static const String animals = '/animals';
  static String animalsByFarm(int farmId) => '/animals/farm/$farmId';
  static String animalById(int id) => '/animals/$id';

  // Veterinarians
  static const String vetsSearch = '/veterinarians/search';
  static const String vetProfile = '/veterinarians/me';
  static const String vetDashboard = '/veterinarians/dashboard';
  static const String specializations = '/specializations';
  static String vetById(int id) => '/veterinarians/$id';
  static String vetsByRegionId(int id) => '/veterinarians/regions/$id';

  // Vet self-management
  static const String vetRegions = '/veterinarians/me/regions';
  static const String vetSpecializations = '/veterinarians/me/specializations';
  static const String vetAvailability = '/veterinarians/me/availability';
  static String vetRegionById(int id) => '/veterinarians/me/regions/$id';
  static String vetSpecById(int id) => '/veterinarians/me/specializations/$id';
  static String vetAvailabilityById(int id) =>
      '/veterinarians/me/availability/$id';

  // Consultations
  static const String consultations = '/consultations';
  static const String myConsultations = '/consultations/my-consultations';
  static const String vetConsultations = '/consultations/veterinarian';
  static String consultationById(int id) => '/consultations/$id';
  static String acceptConsultation(int id) => '/consultations/$id/accept';
  static String rejectConsultation(int id) => '/consultations/$id/reject';
  static String closeConsultation(int id) => '/consultations/$id/close';

  // Medical Records
  static const String medicalRecords = '/medical/records';
  static const String medicalSearch = '/medical/search';
  static String animalMedicalHistory(int animalId) =>
      '/medical/animals/$animalId/history';
  static String medicalRecordById(int id) => '/medical/records/$id';
  static String medicalRecordHistory(int id) => '/medical/records/$id/history';

  // Reviews
  static const String reviews = '/reviews';
  static String reviewById(int id) => '/reviews/$id';
  static String vetReviews(int vetId) => '/reviews/veterinarian/$vetId';

  // Chat
  static const String messages = '/messages';
  static String chatSession(int consultationId) =>
      '/chatsessions/$consultationId';
  static String sessionMessages(int sessionId) =>
      '/messages/session/$sessionId';

  // Regions
  static const String regions = '/regions';

  // Dashboard
  static const String farmerDashboard = '/dashboard';
}
