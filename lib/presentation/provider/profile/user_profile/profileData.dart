import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:collection';
import 'package:shelterstocks_prototype2/domain/models/user_profile/userProfileInfo.dart';

class profileData extends ChangeNotifier{
  int theCurrentStep = 1;
  int totalSteps = 3;



  int? get currentStep{
    return theCurrentStep;
  }



  UserProfile? _currentUserProfile;
  UserProfile? get currentUserProfile => _currentUserProfile;

  profileData(){
    _currentUserProfile = UserProfile();
  }

  void increaseCurrentStep(){
    if(theCurrentStep>0 && theCurrentStep<3){
      theCurrentStep+=1;
    }
    notifyListeners();
  }

  void decreaseCurrentStep(){
    if(theCurrentStep>0 && theCurrentStep<=3){
      theCurrentStep-=1;
    }
    notifyListeners();
  }

  Future<void> updateUserProfile({
    String? maritalStatus,
    String? residentialAddress,
    String? phoneNo,
    String? meansOfId,
    String? idNumber,
    String? issueDate,
    String? expiryDate,
    String? nextOfKinsFullname,
    String? relationshipNOK,
    String? nextOfKinsPhoneno,
    String? nextOfKinsEmail,
    String? nextOfKinsContactAddress,
    String? bankAccountName,
    String? accountNumber,
    String? bank,
    bool? regStatus,
    String? profilePictureUrl,
  }) async {
    // Create a new UserProfile object based on the current one
    // UserProfile updatedProfile = UserProfile(
    //     maritalStatus: maritalStatus ?? _currentUserProfile?.maritalStatus ?? '',
    //     residentialAddress: residentialAddress ?? _currentUserProfile?.residentialAddress ?? '',
    //     phoneNo: phoneNo ?? _currentUserProfile?.phoneNo??'',
    //     meansOfId: meansOfId ?? _currentUserProfile?.meansOfId ?? '',
    //     idNumber: idNumber ?? _currentUserProfile?.idNumber ?? '',
    //     issueDate: issueDate ?? _currentUserProfile?.issueDate ?? '',
    //     expiryDate: expiryDate ?? _currentUserProfile?.expiryDate ?? '',
    //     nextOfKinsFullname: nextOfKinsFullname ?? _currentUserProfile?.nextOfKinsFullname ?? '',
    //     relationshipNOK: relationshipNOK ?? _currentUserProfile?.relationshipNOK ?? '',
    //     nextOfKinsPhoneno: nextOfKinsPhoneno ?? _currentUserProfile?.nextOfKinsPhoneno ?? '',
    //     nextOfKinsEmail: nextOfKinsEmail ?? _currentUserProfile?.nextOfKinsEmail ?? '',
    //     nextOfKinsContactAddress: nextOfKinsContactAddress ?? _currentUserProfile?.nextOfKinsContactAddress ?? '',
    //     bankAccountName: bankAccountName ?? _currentUserProfile?.bankAccountName ?? '',
    //     accountNumber: accountNumber ?? _currentUserProfile?.accountNumber ?? '',
    //     bank: bank ?? _currentUserProfile?.bank ?? '',
    //     regStatus: regStatus ?? _currentUserProfile?.regStatus ?? false,
    //     profilePictureUrl: profilePictureUrl ?? _currentUserProfile?.profilePictureUrl ?? ''
    // );
    UserProfile updatedProfile = UserProfile(
        maritalStatus: maritalStatus ?? _currentUserProfile?.maritalStatus,
        residentialAddress: residentialAddress ?? _currentUserProfile?.residentialAddress,
        phoneNo: phoneNo ?? _currentUserProfile?.phoneNo,
        meansOfId: meansOfId ?? _currentUserProfile?.meansOfId,
        idNumber: idNumber ?? _currentUserProfile?.idNumber,
        issueDate: issueDate ?? _currentUserProfile?.issueDate,
        expiryDate: expiryDate ?? _currentUserProfile?.expiryDate,
        nextOfKinsFullname: nextOfKinsFullname ?? _currentUserProfile?.nextOfKinsFullname,
        relationshipNOK: relationshipNOK ?? _currentUserProfile?.relationshipNOK,
        nextOfKinsPhoneno: nextOfKinsPhoneno ?? _currentUserProfile?.nextOfKinsPhoneno,
        nextOfKinsEmail: nextOfKinsEmail ?? _currentUserProfile?.nextOfKinsEmail,
        nextOfKinsContactAddress: nextOfKinsContactAddress ?? _currentUserProfile?.nextOfKinsContactAddress,
        bankAccountName: bankAccountName ?? _currentUserProfile?.bankAccountName,
        accountNumber: accountNumber ?? _currentUserProfile?.accountNumber,
        bank: bank ?? _currentUserProfile?.bank,
        regStatus: regStatus ?? _currentUserProfile?.regStatus,
        profilePictureUrl: profilePictureUrl ?? _currentUserProfile?.profilePictureUrl
    );
    _currentUserProfile = updatedProfile;

    // Save the updated profile data
    await saveUserProfileData(
      maritalStatus ?? '',
        residentialAddress ?? '',
              phoneNo ?? '',
              meansOfId ?? '',
              idNumber ?? '',
              issueDate ?? '',
              expiryDate ?? '',
              nextOfKinsFullname ?? '',
              relationshipNOK ?? '',
              nextOfKinsPhoneno ?? '',
              nextOfKinsEmail ?? '',
              nextOfKinsContactAddress ?? '',
              bankAccountName ?? '',
              accountNumber ?? '',
              bank ?? '',
              regStatus ?? false, // Ensure regStatus is passed as a non-nullable bool
              profilePictureUrl??''
    );

    notifyListeners();
  }






  Future<void> saveUserProfileData(
      String maritalStatus,
      String resAddress,
      String phoneNo,
      String meansOfId,
      String idNo,
      String issueDate,
      String expiryDate,
      String nokFullname,
      String nokRelation,
      String nokPhoneNo,
      String nokEmail,
      String nokAddress, // Added String type
      String bankAccName,
      String bankAccNo,
      String bank,
      bool regStatus,
      String profilePictureUrl
      ) async {

    final prefs = await SharedPreferences.getInstance();
    // Save user profile data
    await prefs.setString('maritalStatus', maritalStatus);
    await prefs.setString('resAddress', resAddress);
    await prefs.setString('phoneNo', phoneNo);
    await prefs.setString('meansOfId', meansOfId);
    await prefs.setString('idNo', idNo);
    await prefs.setString('issueDate', issueDate);
    await prefs.setString('expiryDate', expiryDate);
    await prefs.setString('nokFullname', nokFullname);
    await prefs.setString('nokRelation', nokRelation);
    await prefs.setString('nokPhoneNo', nokPhoneNo);
    await prefs.setString('nokEmail', nokEmail);
    await prefs.setString('nokAddress', nokAddress);
    await prefs.setString('bankAccName', bankAccName);
    await prefs.setString('bankAccNo', bankAccNo);
    await prefs.setString('bank', bank);
    await prefs.setBool('registration status', regStatus);
    await prefs.setString('profileImageUrl', profilePictureUrl);
  }

  Future<void> loadUserProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    String? maritalStatus = prefs.getString('maritalStatus');
    String? residentialAddress = prefs.getString('resAddress');
    String? phoneNo = prefs.getString('phoneNo');
    String? meansOfId = prefs.getString('meansOfId');
    String? idNumber = prefs.getString('idNo');
    String? issueDate = prefs.getString('issueDate');
    String? expiryDate = prefs.getString('expiryDate');
    String? nextOfKinsFullname = prefs.getString('nokFullname');
    String? relationshipNOK = prefs.getString('nokRelation');
    String? nextOfKinsPhoneno = prefs.getString('nokPhoneNo');
    String? nextOfKinsEmail = prefs.getString('nokEmail');
    String? nextOfKinsContactAddress = prefs.getString('nokAddress');
    String? bankAccountName = prefs.getString('bankAccName');
    String? accountNumber = prefs.getString('bankAccNo');
    String? bank = prefs.getString('bank');
    bool? regStatus = prefs.getBool('registration status')??false;
    String? profilePictureUrl = prefs.getString('profileImageUrl')??'';

    if (maritalStatus != null && residentialAddress != null && phoneNo != null && meansOfId != null && idNumber != null && issueDate != null && expiryDate != null && nextOfKinsFullname != null && relationshipNOK != null && nextOfKinsPhoneno != null && nextOfKinsEmail != null && nextOfKinsContactAddress != null && bankAccountName != null && accountNumber != null && bank != null && regStatus != null
        && profilePictureUrl!=null
    ) {
      _currentUserProfile = UserProfile(
        maritalStatus: maritalStatus,
        residentialAddress: residentialAddress,
        phoneNo: phoneNo,
        meansOfId: meansOfId,
        idNumber: idNumber,
        issueDate: issueDate,
        expiryDate: expiryDate,
        nextOfKinsFullname: nextOfKinsFullname,
        relationshipNOK: relationshipNOK,
        nextOfKinsPhoneno: nextOfKinsPhoneno,
        nextOfKinsEmail: nextOfKinsEmail,
        nextOfKinsContactAddress: nextOfKinsContactAddress,
        bankAccountName: bankAccountName,
        accountNumber: accountNumber,
        bank: bank,
        regStatus: regStatus,
        profilePictureUrl: profilePictureUrl
      );
      notifyListeners();
    } else {
      print('null values');
    }
  }


}

