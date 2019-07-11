import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:countdown/countdown.dart';

// Api de Request dos dados
const request = "https://api.hgbrasil.com/finance?format=json&key=2430c297";
//Define o metodo async

void main() async {
  runApp(MaterialApp(
      title: "Conversor",
      theme: ThemeData(fontFamily: "Work Sans"),
      home: Home()));
}

// Vai retornar a requisição posteriormente
Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final euroController = TextEditingController();
  final dollarController = TextEditingController();

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double real = double.parse(text);
    dollarController.text = (real / dollar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double dolar = double.parse(text);
    realController.text = (dolar * this.dollar).toStringAsFixed(2);
    euroController.text = (dolar * this.dollar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dollarController.text = (euro * this.euro).toStringAsFixed(2);
  }

  void _clearAll() {
    realController.text = "";
    dollarController.text = "";
    euroController.text = "";
  }

  double dollar;
  double euro;

  @override
  Widget build(BuildContext context) {
    _portraitModeOnly();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Color(0xFF23074d), Color(0xFFcc5333)],
            begin: FractionalOffset.topLeft,
            end: FractionalOffset.bottomRight,
            stops: [0.0, 1.0]),
      ),
      child: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: buildLoading(),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                      child: Card(
                    elevation: 11,
                    color: Color(0xFFf0f0f0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11.0),
                    ),
                    child: Container(
                      width: 300.0,
                      height: 200.0,
                      child: Column(children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 50, 20, 40),
                          child: Text(
                            "Erro ao recuperar os dados",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF23074d),
                                    Color(0xFFcc5333)
                                  ],
                                  begin: FractionalOffset.topLeft,
                                  end: FractionalOffset.bottomRight,
                                  stops: [0.0, 1.0])),
                          child: MaterialButton(
                            onPressed: () {
                              runApp(MaterialApp(
                                home: Home(),
                              ));
                            },
                            highlightColor: Colors.transparent,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                "Recarregar",
                                style: TextStyle(
                                    fontSize: 22, color: Colors.white),
                              ),
                            ),
                          ),
                        )
                      ]),
                    ),
                  ));
                } else {
                  dollar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(top: 60),
                            child: Stack(
                              overflow: Overflow.visible,
                              children: <Widget>[
                                Card(
                                  color: Color(0xFF0923074d),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100)),
                                  elevation: 50,
                                  child: Icon(
                                    Icons.monetization_on,
                                    size: 160,
                                    color: Color(0xFFf0f0f0),
                                  ),
                                )
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.only(top: 50),
                            child: Card(
                              elevation: 11,
                              color: Color(0xFFf0f0f0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11.0),
                              ),
                              child: Container(
                                width: 300.0,
                                height: 350.0,
                                child: Column(children: <Widget>[
                                  Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(35, 50, 35, 15),
                                      child: buildTextField("R\$", "Real",
                                          realController, _realChanged)),
                                  buildDivider(),
                                  Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(35, 15, 35, 15),
                                      child: buildTextField("US\$", "Dólar",
                                          dollarController, _dolarChanged)),
                                  buildDivider(),
                                  Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(35, 15, 35, 15),
                                      child: buildTextField("€", "Euro",
                                          euroController, _euroChanged)),
                                  buildDivider()
                                ]),
                              ),
                            ))
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildLoading() {
  return CircularProgressIndicator(backgroundColor: Color(0xFFf0f0f0));
}

Widget buildTextField(String suffix, String hint,
    TextEditingController controller, Function changes) {
  return TextField(
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    style: TextStyle(fontSize: 18, fontFamily: "Work Sans"),
    decoration: InputDecoration(
        suffixText: suffix,
        border: InputBorder.none,
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w400,
        )),
    onChanged: changes,
  );
}

Widget buildDivider({int width, int height}) {
  return Container(
    width: width ?? 250,
    height: height ?? 1,
    color: Colors.grey[400],
  );
}

void _portraitModeOnly() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
