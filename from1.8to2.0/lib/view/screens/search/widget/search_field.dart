import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData suffixIcon;
  final Function iconPressed;
  final Color filledColor;
  final Function onSubmit;
  final Function onChanged;
  SearchField({@required this.controller, @required this.hint, @required this.suffixIcon, @required this.iconPressed, this.filledColor, this.onSubmit, this.onChanged});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), borderSide: BorderSide.none),
        filled: true, fillColor: widget.filledColor ?? Theme.of(context).cardColor,
        isDense: true,
        suffixIcon: IconButton(
          onPressed: widget.iconPressed,
          icon: Icon(widget.suffixIcon, color: Theme.of(context).textTheme.bodyLarge.color),
        ),
      ),
      onSubmitted: widget.onSubmit,
      onChanged: widget.onChanged,
    );
  }
}
