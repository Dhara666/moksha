import 'package:flutter/material.dart';

Widget commonTextButton({String? buttonText,Function? function}){
  return TextButton(
    onPressed:(){
      function!();
    },
    child: Text(
      buttonText!,
      style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors
              .black),
    ),
  );
}