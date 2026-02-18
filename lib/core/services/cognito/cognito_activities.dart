//libraries
import 'package:flutter/material.dart';
//state management
import 'package:provider/provider.dart';
//amplify
import 'package:amplify_flutter/amplify_flutter.dart';
//models
import 'package:foretale_application/models/user_details_model.dart'; // Ensure this path is correct

Future<void> getUserSignInDetails(BuildContext context) async {
  try {
    var userModel = Provider.of<UserDetailsModel>(context, listen: false);

    //check if the user is already initialized
    if(userModel.isUserInitialized(context)) {
      return;
    }

    // Check if the user is currently signed in
    var user = await Amplify.Auth.getCurrentUser();
    
    // Get user attributes
    var userAttributes = await Amplify.Auth.fetchUserAttributes();

    // Find the email attribute
    var emailAttribute = userAttributes.firstWhere(
      (attr) => attr.userAttributeKey.toString() == 'email',
      orElse: () => const AuthUserAttribute(userAttributeKey: AuthUserAttributeKey.email, value: "empty_email_address"),
    );

    // Handle missing name attribute
    var nameAttribute = userAttributes.firstWhere(
      (attr) => attr.userAttributeKey.toString() == 'name',
      orElse: () => const AuthUserAttribute(userAttributeKey: AuthUserAttributeKey.name, value: "empty_name"),
    );

    if(emailAttribute.value != "empty_email_address"){
      //save details to the model
      userModel.saveUserDetails(
        user.userId,
        nameAttribute.value,
        emailAttribute.value,
      );

      //setup an user record in the database
      //userModel.initializeUser(context);

    } else {
      throw Exception('Unable to find the associated email address.');
    }

  } catch (e) {
    throw Exception('Unable to get user details. Please try again later.');
  }
}

/// Lightweight method to check if a user is currently authenticated
/// Returns true if user is signed in, false otherwise
Future<bool> isUserAuthenticated() async {
  try {
    // Check if there's a current user session
    await Amplify.Auth.getCurrentUser();
    return true;
  } catch (e) {
    // User is not authenticated
    return false;
  }
}

/// Sign out the current user from Amplify and clear user details
/// This will automatically redirect to the login screen via the Authenticator widget
Future<void> signOut(BuildContext context) async {
  try {
    var userModel = Provider.of<UserDetailsModel>(context, listen: false);
    
    // Sign out from Amplify
    await Amplify.Auth.signOut();
    
    // Clear user details from the model
    userModel.clearUserDetails();
    
    // The Authenticator widget will automatically show the login screen
    // when the user is signed out, so no manual navigation is needed
  } catch (e) {
    // Re-throw the error so it can be handled by the caller
    throw Exception('Failed to sign out: ${e.toString()}');
  }
}
