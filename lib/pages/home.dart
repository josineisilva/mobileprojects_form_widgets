import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State {
  // Chave para o formulario
  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();
  // Chave para o Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Modelo de dados
  final _user = User();

  @override
  Widget build(BuildContext context) {
    bool desenvolvimento = _user.preferencias[User.PreferenciasDesenvolvimento];
    bool redes = _user.preferencias[User.PreferenciasRedes];
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Profile')),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Builder(
          builder: (context) => Form(
            key: _formStateKey,
            autovalidate: true,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    initialValue: _user.nome,
                    decoration: InputDecoration(labelText: 'Nome'),
                    validator: (value) => _validateNome(value),
                    onSaved: (value) => setState(() => _user.nome = value),
                  ),
                  TextFormField(
                    initialValue:
                      (_user.idade ?? 0)>=18 ? _user.idade.toString() : '',
                    inputFormatters:
                      [WhitelistingTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Idade'),
                    validator: (value) => _validateIdade(value),
                    onSaved: (value) =>
                      setState(() => _user.idade = int.tryParse(value)),
                  ),
                  Divider(),
                  FormField(
                    validator: (value) => _validateEstCiv(value),
                    onSaved: (value) =>
                      setState(() => _user.estciv = value),
                    initialValue: _user.estciv,
                    builder: (FormFieldState<String> state) {
                      return Column(children: <Widget>[
                        ListTile(
                          title: Text('Estado Civil:'),
                        ),
                        RadioListTile<String>(
                          title: const Text('Solteiro'),
                          value: 'solteiro',
                          groupValue: state.value,
                          onChanged: (value) => state.didChange(value),
                        ),
                        RadioListTile<String>(
                          title: const Text('Casado'),
                          value: 'casado',
                          groupValue: state.value,
                          onChanged: (value) => state.didChange(value),
                        ),
                        RadioListTile<String>(
                          title: const Text('Outro'),
                          value: 'outro',
                          groupValue: state.value,
                          onChanged: (value) => state.didChange(value),
                        ),
                        state.hasError ?
                          Text(
                            state.errorText,
                            style: TextStyle(color: Colors.red),
                          )
                        :
                          Container()
                      ]);
                    }
                  ),
                  Divider(),
                  FormField(
                    validator: (value) => _validateAtuacao(value),
                    onSaved: (value) =>
                      setState(() => _user.atuacao = value),
                    initialValue: _user.atuacao,
                    builder: (FormFieldState<String> state) {
                      return Column(children: <Widget>[
                        ListTile(
                          title: Text('Atuacao'),
                          trailing: DropdownButton<String>(
                            value: state.value,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            onChanged: (value) => state.didChange(value),
                            items: _user.Atuacao
                              .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }
                            ).toList(),
                          ),
                        ),
                        state.hasError ?
                          Text(
                            state.errorText,
                            style: TextStyle(color: Colors.red),
                          )
                        :
                          Container()
                      ]);
                    }
                  ),
                  Divider(),
                  FormField(
                    onSaved: (value) =>
                      setState(() => _user.newsletter = value),
                    initialValue: _user.newsletter?? false,
                    builder: (FormFieldState<bool> state) {
                      return SwitchListTile(
                        title: const Text('Enviar Newsletter'),
                        value: state.value,
                        onChanged: (bool value) => state.didChange(value)
                      );
                    }
                  ),
                  Divider(),
                  CheckboxListTile(
                    title: const Text('Hardware'),
                    value: _user.preferencias[User.PreferenciasHardware],
                    onChanged: (val) {
                      setState(() =>
                        _user.preferencias[User.PreferenciasHardware] = val);
                    }
                  ),
                  FormField(
                    onSaved: (value) =>
                      setState(() =>
                        _user.preferencias[User.PreferenciasDesenvolvimento] = value
                    ),
                    initialValue: desenvolvimento?? false,
                    builder: (FormFieldState<bool> state) {
                      return CheckboxListTile(
                        title: const Text('Desenvolvimento'),
                        value: state.value,
                        onChanged: (bool value) => state.didChange(value)
                      );
                    }
                  ),
                  FormField(
                    onSaved: (value) =>
                      setState(() =>
                        _user.preferencias[User.PreferenciasRedes] = value
                    ),
                    initialValue: redes?? false,
                    builder: (FormFieldState<bool> state) {
                      return CheckboxListTile(
                        title: const Text('Redes'),
                        value: state.value,
                        onChanged: (bool value) => state.didChange(value)
                      );
                    }
                  ),
                ]
              ),
            )
          )
        )
      ),
      bottomNavigationBar: ButtonBar(
        alignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          RaisedButton(
              onPressed: () => _user.show(),
              child: Text('Exibir')
          ),
          RaisedButton(
              onPressed: () => _submit(),
              child: Text('Save')
          ),
        ],
      ),
    );
  }

  //
  // Validar o nome
  //
  String _validateNome(String value) {
    String ret = null;
    value = value.trim();
    if ( value.isEmpty )
      ret = "Enter com o nome";
    return ret;
  }

  //
  // Validar a idade
  //
  String _validateIdade(String value) {
    String ret = null;
    value = value.trim();
    if ( value.isEmpty )
      ret = "Idade e obrigatoria";
    else {
      int _valueAsInteger = int.tryParse(value);
      if ( _valueAsInteger == null )
        ret = "Valor invalido";
      else {
        if ( _valueAsInteger < 18 )
          ret = "Valor deve ser maior que 18";
      }
    }
    return ret;
  }

  //
  // Validar o estado civil
  //
  String _validateEstCiv(String value) {
    String ret = null;
    if ( value == null )
      ret = "Enter com o estado civil";
    return ret;
  }

  //
  // Validar a atuacao
  //
  String _validateAtuacao(String value) {
    String ret = null;
    if ( value == null )
      ret = "Enter com o estado civil";
    return ret;
  }

  //
  // Verifica e salva os dados do formulario
  //
  _submit() {
    if(_formStateKey.currentState.validate()) {
      _formStateKey.currentState.save();
      _user.save();
      _user.show();
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text('Submitting form'))
      );
    }
  }
}
