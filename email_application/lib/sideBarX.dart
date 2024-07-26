import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

class ExampleSidebarX extends StatelessWidget {
  const ExampleSidebarX({
    Key? key,
    required this.controller,
    required this.onSelectIndex,
    required this.onComposeEmail,
  }) : super(key: key);

  final SidebarXController controller;
  final ValueChanged<int> onSelectIndex;
  final VoidCallback onComposeEmail;

  @override
  Widget build(BuildContext context) {
    var sz = MediaQuery.of(context).size;
    return SidebarX(
      controller: controller,
      theme: SidebarXTheme(
        width: sz.width / 14,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: canvasColor,
        ),
        hoverColor: scaffoldBackgroundColor,
        textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        selectedTextStyle: const TextStyle(color: Colors.white),
        hoverTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: canvasColor),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: actionColor.withOpacity(0.37),
          ),
          gradient: const LinearGradient(
            colors: [accentCanvasColor, canvasColor],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 30,
            )
          ],
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
      ),
      extendedTheme: SidebarXTheme(
        width: sz.width / 7,
        decoration: BoxDecoration(
          color: canvasColor,
        ),
      ),
      headerBuilder: (context, extended) {
        var sz = MediaQuery.of(context).size;
        return Container(
          margin: EdgeInsets.only(bottom: sz.height / 46),
          padding: EdgeInsets.all(sz.height / 92),
          child: Align(
            alignment: extended ? Alignment.centerLeft : Alignment.center,
            child: ElevatedButton.icon(
              onPressed: onComposeEmail,
              icon: Icon(Icons.edit, color: canvasColor),
              label: extended ? Text('Soạn thư', style: TextStyle(color: canvasColor)) : SizedBox(width: 0, height: 0,),
              style: TextButton.styleFrom(
                padding: extended ? EdgeInsets.all(sz.height / 35) : EdgeInsets.all(sz.height / 35),
                alignment: extended ? Alignment.centerLeft : Alignment.center,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        );
      },
      items: [
        SidebarXItem(
          icon: Icons.home,
          label: 'Hộp thư đến',
          onTap: () {
            onSelectIndex(0);
          },
        ),
        SidebarXItem(
          icon: Icons.send,
          label: 'Đã gửi',
          onTap: () {
            onSelectIndex(1);
          },
        ),
        SidebarXItem(
          icon: Icons.star,
          label: 'Có gắn dấu sao',
          onTap: () {
            onSelectIndex(1);
          },
        ),
        SidebarXItem(
          icon: Icons.people,
          label: 'Thư rác',
          onTap: () {
            onSelectIndex(2);
          },
        ),
        SidebarXItem(
          icon: Icons.favorite,
          label: 'Spam/Ham',
          onTap: () {
            onSelectIndex(3);
          },
        ),
        SidebarXItem(
          icon: Icons.delete,
          label: 'Thùng rác',
          onTap: () {
            onSelectIndex(4);
          },
        ),
      ],
    );
  }
}

const primaryColor = Color(0xFF685BFF);
const canvasColor = Color(0xFF316AB7);
const scaffoldBackgroundColor = Color.fromRGBO(112, 179, 255, 0.612);
const accentCanvasColor = Color.fromARGB(255, 192, 192, 207);
const white = Colors.white;
final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);
final divider = Divider(color: white.withOpacity(0.3), height: 1);