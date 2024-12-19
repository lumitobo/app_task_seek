import 'package:flutter/material.dart';

class CustomFilledButton extends StatelessWidget {

  final void Function()? onPressed;
  final String text;
  final Color? buttonColor;
  final bool loading;

  const CustomFilledButton({
    super.key, 
    this.onPressed, 
    required this.text, 
    this.buttonColor,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {

    const radius = Radius.circular(10);

    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: buttonColor,
        shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: radius,
          bottomRight: radius,
          topLeft: radius,
        )
      )),
        
  
      onPressed: onPressed, 
      child: loading ? const SizedBox(width: 25, height: 25, child: CircularProgressIndicator(color: Colors.white,strokeWidth: 2)) : Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
    );
  }
}