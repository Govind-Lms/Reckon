import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:invoice_reckon/screens/sales/widgets/customer_detail_card.dart';
import 'package:url_launcher/url_launcher.dart';

class SalesClientDetail extends StatefulWidget {
  final String custId,name,phoneNo,email,kpayNumber,waveNumber,imageUrl;

  SalesClientDetail({this.custId, this.name, this.phoneNo, this.email, this.kpayNumber, this.waveNumber, this.imageUrl});

  _SalesClientDetailState createState() => _SalesClientDetailState();
}

class _SalesClientDetailState extends State<SalesClientDetail> {
  TextEditingController _numberCtrl = new TextEditingController();
  TextEditingController _emailCtrl = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailCtrl.text= widget.email;
    _numberCtrl.text = widget.phoneNo;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          'Client: ${widget.name}'
        ),
      ),
      body: ListView(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ClipPath(
                clipper: CustomClipPath(),
                child: Container(
                  height: 200.0,
                  color: Colors.redAccent,
                ),
              ),
              Positioned(
                top: 45.0,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(200.0),
                      border: Border.all(width: 1.0,color: Colors.deepPurple)
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(200.0),
                    child: CachedNetworkImage(
                      width: 150.0,
                      height: 150.0,
                      imageUrl: widget.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: (){
                  print('calling');
                  FlutterPhoneDirectCaller.callNumber(_numberCtrl.text);
                },
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width/2 -50,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                  decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(.7),
                      borderRadius: BorderRadius.circular(5.0)
                  ),
                  child: Text(
                    "Call Now",
                    style: TextStyle(
                        fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              InkWell(
                onTap: (){
                  _launchURL('${widget.email}', 'Sample Subject', 'Hello Sir,');
                },
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width/2 -50,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                  decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(.7),
                      borderRadius: BorderRadius.circular(5.0)
                  ),
                  child: Text(
                    "Email",
                    style: TextStyle(
                        fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.0,),
          Row(

            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              customerCard('${widget.phoneNo}', Icons.phone, 'Mobile'),
              customerCard('${widget.email}', Icons.mail, 'Email'),

            ],
          ),
          SizedBox(height: 10.0,),
          Row(

            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              customerCard('${widget.kpayNumber}', Icons.payment, 'KBZ Pay'),
              customerCard('${widget.waveNumber}', Icons.payment, 'Wave Pay'),

            ],
          ),
          SizedBox(
            height: 20.0,
          ),
        ],
      ),
    );
  }
  _launchURL(String toMailId, String subject, String body) async {
    var url = 'mailto:$toMailId?subject=$subject&body=$body';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}


class CustomClipPath extends CustomClipper<Path>{
  var radius=30.0;
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 100);
    path.quadraticBezierTo(
        size.width / 2, size.height,
        size.width, size.height - 100);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
