import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wfm/models/user_model.dart';
import 'package:wfm/api/user_api.dart';
import 'package:wfm/pages/list_orders.dart';
import 'package:wfm/pages/widgets/message_widgets.dart';

import '../api/auth_api.dart';

class UsersScreen extends StatefulWidget {
  final String token;
  const UsersScreen({super.key, required this.token});

  @override
  UsersScreenState createState() => UsersScreenState();
}

class UsersScreenState extends State<UsersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: FutureBuilder<List<User>>(
        future: UserApi.fetchUsers(widget.token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading users.'),
            );
          } else if (snapshot.hasData) {
            // Display the list of users here
            List<User> users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemBuilder: (context, index) {
                return ExpansionTile(
                  title: Text(users[index].name),
                  subtitle: Text(users[index].email),
                  childrenPadding: const EdgeInsets.symmetric(vertical: 12),
                  shape: Border.all(color: Colors.transparent),
                  children: <Widget>[
                    Row(
                      // mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () async {
                            bool confirm = await resetPasswordPrompt(
                                context, users[index].email);
                            if (confirm) {
                              var response = await UserApi.resetPassword(
                                  widget.token, users[index].email);
                              if (mounted) {
                                Navigator.pop(context);
                                snackbarMessage(context, response['success']);
                              }
                            } else {
                              return;
                            }
                          },
                          child: const Text('Reset Password'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () async {
                            bool confirm = await logOutUserPrompt(
                                context, users[index].email);
                            if (confirm) {
                              var response = await AuthApi.logOutUser(
                                  widget.token, users[index].email);
                              if (mounted) {
                                Navigator.pop(context);
                                snackbarMessage(context, 'Log out command sent!');
                              }
                            } else {
                              return;
                            }
                          },
                          child: const Text('Force Logout'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          } else {
            return const Center(
              child: Text('No users found.'),
            );
          }
        },
      ),
    );
  }
}

class UpdatePassword extends StatefulWidget {
  final String userEmail;
  const UpdatePassword({super.key, required this.userEmail});

  @override
  State<UpdatePassword> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  bool _isPasswordVisible = false;
  bool _isRePasswordVisible = false;
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _pwcController = TextEditingController();
  final GlobalKey<FormState> _updatePwFormKey = GlobalKey<FormState>();

  late SharedPreferences prefs;
  late String? token;
  late String? user;

  @override
  void dispose() {
    _pwController.dispose();
    _pwcController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getPrefs();
    super.initState();
  }

  getPrefs() async {
    prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    user = prefs.getString('user');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Password'),
      ),
      body: Form(
        key: _updatePwFormKey,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(25))
                    ),
                    alignment: Alignment.center,
                    height: 260,
                    width: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 18,),
                          const Text(
                            "Updating password for:",
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              widget.userEmail,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.indigo
                              ),
                            ),
                          ),
                          const SizedBox(height: 20,),
                          const Text(
                            "Password must contain:",
                            style: TextStyle(
                                  fontSize: 14,
                            ),
                          ),
                          const Text(
                            "- a minimum of 8 letters",
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const Text(
                            "- uppercase & lowercase letters",
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const Text(
                            "- a number",
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const Text(
                            "- a special character (e.g. * @ & ^ %)",
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12,),
                          const Text(
                            'Example: "ex@Mple1"',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8,),
                        ],
                      )),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _pwController,
                  autofocus: false,
                  obscureText: !_isPasswordVisible,
                  onSaved: (input) => _pwController.text = input ?? "Empty email",
                  validator: (value) {
                    // add email validation
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }

                    if (value.length < 8) {
                      return 'Password must have at least 8 characters';
                    }

                    if (!value.contains(RegExp(r'[A-Z]')) || !value.contains(RegExp(r'[a-z]'))) {
                      return 'Password must have uppercase and lowercase letters';
                    }

                    // Check if the password has at least one special character and one number
                    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')) ||
                        !value.contains(RegExp(r'[0-9]'))) {
                      return 'Password must have at least one special character and one number';
                    }

                    return null;
                  },
                  decoration: InputDecoration(
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      labelText: 'New Password',
                      hintText: 'Enter new password',
                      // prefixIcon: const Icon(Icons.lock_outline_rounded),
                      border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      )),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _pwcController,
                  autofocus: false,
                  obscureText: !_isRePasswordVisible,
                  onSaved: (input) => _pwcController.text = input ?? "Empty email",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }

                    if (_pwcController.text != _pwController.text) {
                      return 'Password mismatched';
                    }

                    return null;
                  },
                  decoration: InputDecoration(
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      labelText: 'Re-enter New Password',
                      hintText: 'Confirm new password',
                      // prefixIcon: const Icon(Icons.lock_outline_rounded),
                      border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      suffixIcon: IconButton(
                        icon: Icon(_isRePasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _isRePasswordVisible = !_isRePasswordVisible;
                          });
                        },
                      )),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(onPressed: () async {
                  if (_updatePwFormKey.currentState?.validate() ?? false) {
                    showLoaderDialog(context);
                    await Future.delayed(const Duration(milliseconds: 1400));
                    var response = await UserApi.updatePassword(
                        token,
                        widget.userEmail,
                        _pwController.text
                    );
                    if (mounted) {
                      Navigator.pop(context);
                      if(response['success'] != null){
                        _pwController.clear();
                        _pwcController.clear();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkOrders(user: user ?? "Loading...", email: widget.userEmail),
                          ),
                        );
                        snackbarMessage(context, response['success']);
                      }else{
                        colorSnackbarMessage(context, response['failed'], Colors.red);
                      }
                    }
                  }
                }, child: const Text("Update"))
              ],
            ),
          ),
        ),
      ),
    );
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.only(left: 7),
              child: const Text("Updating password...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () async => false,
            child: alert
        );
      },
    );
  }
}
