import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:hex/hex.dart';
import 'package:sha3/sha3.dart';
import 'package:ymgkproje/note.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' show Client;
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:image/image.dart' as Images;
import 'dart:math';
import 'api.dart';

class FotoEkle extends StatefulWidget {
  @override
  _FotoEkleState createState() => _FotoEkleState();
  File yeniimage;
  Future<List<int>> encrypt(var KEY, File image) async {
    // load avatar image
    // ByteData imageData = await image.readAsBytes();
    List<int> bytes =
        await image.readAsBytes(); //Uint8List.view(imageData.buffer);
    var avatarImage = Images.decodeImage(bytes);

    //var a = 'dd121e36961a04627eacff629765dd3528471ed745c1e32222db4a8a5f3421c4';
    //a değeri api'den gelen xor'lanacak anahtar(key) değeri
    List<int> xr = List<int>(); //xor listesi
    int xor = 0, pikseller = 0;
    for (int y = 0; y <= avatarImage.height; y++) {
      for (int x = 0; x <= avatarImage.width; x++) {
        pikseller =
            avatarImage.getPixelSafe(x, y); //sıra ile her piksel çekiliyor.
        //getPixelSafe metodu, resmin x ve y koordinatındaki pixel byte değerini alıyor.
        xor = pikseller.hashCode ^ KEY.hashCode; //pikseller xor'lanıyor

        xr.add(
            xor); //xr listesine xor'lanmıs degerler atılıyor. Bu xr listesini
        //asagida verilen fraktal ile zigzag cizerek piksel değerine atıyor.
      }
    }
    //FRAKTAL
    int mboyut = avatarImage.width; //resmin genisligi
    int nboyut = avatarImage.length; //resmin yuksekligi
    int say = 0;
    int ortanokta = (sqrt(nboyut * mboyut) - 1).toInt();
    int adimlimit = ortanokta * 2 + 1, Y, X;
    bool ortaknt = true;

    for (int Z = 0; Z < adimlimit; Z++) {
      int adimmod = Z % ortanokta;
      if (ortaknt) {
        if (Z % 2 == 0) {
          X = mboyut - 1;
          Y = Z;
          for (int i = 0; i < Z + 1; i++) {
            say++;
            avatarImage.setPixelSafe(X, Y,
                xr[i]); //xr listesindeki elemanları sırası ile renk byte'ı olarak setPixel yapıyor.
            X--;
            Y--;
          }
        } else {
          X = mboyut - 1 - Z;
          Y = 0;

          for (int i = 0; i < Z + 1; i++) {
            say++;
            avatarImage.setPixelSafe(X, Y, xr[i]); //ayni aciklama ustteki ile
            X++;
            Y++;
          }
        }
        if (Z == ortanokta) {
          ortaknt = false;
        }
      } else {
        if (adimmod % 2 == 0) {
          if (say == nboyut * mboyut - 1) {
            X = 0;
            Y = nboyut - 1;
            adimmod = ortanokta;
          } else {
            X = 0;
            Y = adimmod;
          }
          for (int i = 0; i < (ortanokta - adimmod + 1); i++) {
            avatarImage.setPixelSafe(X, Y, xr[i]); //ayni aciklama ustteki ile
            say++;
            X++;
            Y++;
          }
        } else {
          if (say == nboyut * mboyut - 1) {
            X = 0;
            Y = nboyut - 1;
            adimmod = ortanokta;
          } else {
            X = mboyut - adimmod;
            Y = nboyut - 1;
          }
          for (int i = 0; i < (ortanokta - adimmod + 1); i++) {
            avatarImage.setPixelSafe(X, Y, xr[i]); //ayni aciklama ustteki ile
            say++;
            X--;
            Y--;
          }
        }
      }
    } //FRAKTAL SONU
    var avatarImage2 = Images.grayscale(avatarImage); 
    return Images.encodeJpg(avatarImage2);
  }

  //DECRYPT
  Future<List<int>> fdecrypt() async {
    ByteData imageData = await rootBundle.load('dosyalar/palet.jpg');
    List<int> bytes = Uint8List.view(imageData.buffer);
    var decImage = Images.decodeImage(bytes);
    return Images.encodeJpg(decImage);
  }
}
 
class _FotoEkleState extends State<FotoEkle> {
  final soruKontrolcu = GlobalKey<FormState>();
  String soruhakkinda;
  String sorubasligi;
  File _imageFile;
  String yeniKod = "";
  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);
    setState(() {
      _imageFile = selected;
    });
  }

  void Sha3CreateCode(var gelenDeger) {
    var k = SHA3(256, SHA3_PADDING, 256);
    k.update(utf8.encode(gelenDeger));
    var hash = k.digest();
    //debugPrint(" SHA3 Çıktısı: " + HEX.encode(hash));
    setState(() {
      yeniKod = HEX.encode(hash).toString();
    });
  }

  List<int> _myImage;
  Timer _timer;
  void startTimer1() {
    Fluttertoast.showToast(
        msg: "Lütfen Bekleyiniz..",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);

    int _start = 5;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(() {
        if (_start < 1) {
          timer.cancel();
          myImage = null;
          Fluttertoast.showToast(
              msg: "Şifreleme Kaldırıldı!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          _start = _start - 1;
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "PHOTOCRIPTO",
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFF31a0d5),
        ),
        body: SingleChildScrollView(
          child: Container(
              child: Container(
            height: _height,
            width: _width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 1.0],
                colors: [
                  Color(0xFFeeaeca),
                  Color(0xFF94bbe9),
                ],
              ),
            ),
            child: Column(children: <Widget>[
              Column(
                children: [
                  if (_imageFile != null) ...[
                    Image.file(
                      _imageFile,
                      width: _width * 0.5,
                      height: _height * 0.3,
                    ),
                  ] else ...[
                    SizedBox(height: _height * 0.3),
                  ]
                ],
              ),
              Column(
                children: [
                  if (myImage != null) ...[
                    Image.memory(
                      myImage,
                      width: _width * 0.5,
                      height: _height * 0.3,
                    ),
                  ] else ...[
                    SizedBox(height: _height * 0.3),
                  ]
                ],
              ),
              Text(
                "Fotoğrafın boyutuna göre şifreleme \n işlemi süresi artmaktadır. \n Hızlı olması için düşük çözünürlükte \n görsel seçiniz!",
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    child: RaisedButton(
                      onPressed: () {
                        _pickImage(ImageSource.gallery);
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: BorderSide(color: Color(0xFF94bbe9))),
                      child: Text("Galeri"),
                      splashColor: Color(0xFFeeaeca),
                      color: Color(0xFF94bbe9),
                    ),
                  ),
                  SizedBox(width: 20),
                  Container(
                    width: 100,
                    child: RaisedButton(
                      onPressed: () {
                        _pickImage(ImageSource.camera);
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: BorderSide(color: Color(0xFF94bbe9))),
                      child: Text("Kamera"),
                      splashColor: Color(0xFFeeaeca),
                      color: Color(0xFF94bbe9),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    child: RaisedButton(
                      onPressed: () {
                        Sha3CreateCode(
                            _imageFile.hashCode.bitLength.toString());
                        createKod(yeniKod);
                        var kod = yeniKod;
                        mencrypt(kod, _imageFile);
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: BorderSide(color: Color(0xFF94bbe9))),
                      child: Text("Şifrele"),
                      splashColor: Color(0xFFeeaeca),
                      color: Color(0xFF94bbe9),
                    ),
                  ),
                  SizedBox(width: 20),
                  Container(
                    width: 100,
                    child: RaisedButton(
                      onPressed: () {
                        if (myImage == null) {
                          Fluttertoast.showToast(
                              msg: "Fotoğraf Seçilmedi!",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                        else{decrypt();
                        startTimer1();}
                        
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: BorderSide(color: Color(0xFF94bbe9))),
                      child: Text("Çöz"),
                      splashColor: Color(0xFFeeaeca),
                      color: Color(0xFF94bbe9),
                    ),
                  ),
                ],
              ),
            ]),
          )),
        ));
  }

  List<int> myImage;

  void mencrypt(var KEY, File image) {
    widget.encrypt(KEY, image).then((List<int> image) {
      setState(() {
        myImage = image;
        print(myImage.toString());
      });
    });
  }

  void decrypt() {}

  Future<Album> createKod(String title) async {
    final http.Response response = await http.post(
      'https://cleanpagesoft.com/YmgkApi/createKey.php',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'key': title,
      }),
    );
    var veri = jsonDecode(response.body);
    yeniKod = veri["key"].toString();
    if (response.statusCode == 200) {
      return Album.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Albüm Yüklenemedi');
    }
  }
}
