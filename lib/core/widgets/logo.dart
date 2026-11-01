import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final double width;
  final double height;
  final double fontSize;
  final bool isExpanded;
  const Logo({
    Key? key,
    this.width = 200,
    this.height = 220,
    this.fontSize = 26,
    this.isExpanded = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // color: Theme.of(context).primaryColor,
      height: height,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isExpanded)
              Expanded(
                child: SizedBox(
                  width: width,
                  child: Image(
                    image: AssetImage("assets/app_logo.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Center(
                child: SizedBox(
                  width: width,
                  child: Image(
                    image: AssetImage("assets/app_logo.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
