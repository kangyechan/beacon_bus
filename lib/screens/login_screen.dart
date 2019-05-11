import 'package:flutter/material.dart';
import 'package:beacon_bus/blocs/login/login_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:beacon_bus/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progress_hud_v2/progress_hud.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = LoginProvider.of(context);
    bloc.setContext(context);
    init(context, bloc);
    return Scaffold(
      body: _buildBody(context, bloc),
    );
  }

  Widget _buildBody(BuildContext context, LoginBloc bloc) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: ListView(
            children: <Widget>[
              SizedBox(height: 200.0,),
              Image.asset('images/background.JPG'),
              _emailField(bloc),
              _passwordField(bloc),
              _loginButton(bloc),

            ],
          ),
        ),
        _buildProgressHud(bloc),
      ],
    );
  }

  Widget _buildProgressHud(LoginBloc bloc) {
    return StreamBuilder<Object>(
        stream: bloc.loading,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();
          bool loading = snapshot.data;
          print(loading);
          double opacity = 0;
          opacity = loading ? 1.0 : 0.0;
          return Opacity(opacity: opacity, child: ProgressHUD(
            backgroundColor: Colors.black12,
            color: Colors.white,
            containerColor: Theme.of(context).accentColor,
            borderRadius: 5.0,
            text: '',
          ),);
        }
    );
  }

  Widget _emailField(LoginBloc bloc) {
    return StreamBuilder(
      stream: bloc.email,
      builder: (context, snapshot) {
        return TextField(
          onChanged: bloc.changeEmail,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
              hintText: 'you@example.com',
              labelText: 'Email Address',
              errorText: snapshot.error
          ),
        );
      },
    );
  }

  Widget _passwordField(LoginBloc bloc) {
    return StreamBuilder(
      stream: bloc.password,
      builder: (context, snapshot) {
        return TextField(
          onChanged: bloc.changePassword,
          decoration: InputDecoration(
            hintText: 'Password',
            labelText: 'Password',
            errorText: snapshot.error,
          ),
        );
      },
    );
  }

  Widget _loginButton(LoginBloc bloc) {
    return StreamBuilder(
      stream: bloc.submitValid,
      builder: (context, snapshot) {
        return RaisedButton(
            child: Text('로그인'),
            color: Theme.of(context).accentColor,
            onPressed: snapshot.hasData ? () => bloc.submit() : null,
        );
      },
    );
  }

  void init(BuildContext context, LoginBloc bloc) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userType = prefs.getString(USER_TYPE);
    print(userType);
    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      if (user != null) {
        String userType = bloc.prefs.getString(USER_TYPE);
        if (userType == "teacher") {
          Navigator.pushNamedAndRemoveUntil(context, '/teacher', (Route r) => false);
        } else if (userType == "parent") {
          Navigator.pushNamedAndRemoveUntil(context, '/parent', (Route r) => false);
        }
      }
    });
  }
}
