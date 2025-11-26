import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

// void main() {
//   runApp(CryptoText());
// }

// class CryptoText extends StatelessWidget {
//   const CryptoText({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Crypto Text',
//       home: HomeScreen(),
//     );
//   }
// }

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  //Kunci untuk enkripsi dan deskripsi
  final encrypt.Key _key = encrypt.Key.fromLength(32);
  //Initial vector untuk enskripsi dan deskripsi
  final iv = encrypt.IV.fromLength(16);

  String _encryptedText = '';
  String _decryptedText = '';
  String? _errorText;
  bool _isDecryptButtonEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crypto Text')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                labelText: 'Input Text',
                errorText: _errorText,
                border: const OutlineInputBorder(),
              ),
              onChanged: _onTextChanged,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String inputText = _textEditingController.text;

                if (inputText.isNotEmpty) {
                  _encryptText(inputText);
                } else {
                  setState(() {
                    _errorText = 'Input cannot be empty';
                  });
                }
              },
              child: const Text('Encrypt'),
            ),
            SizedBox(height: 10),
            Text(
              'Encrypted text: $_encryptedText',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isDecryptButtonEnabled && _encryptedText.isNotEmpty
                  ? () {
                      String inputText = _encryptedText;
                      final encrypted = encrypt.Encrypted.fromBase64(inputText);
                      _decryptText(encrypted.base64);
                    }
                  : null,
              child: const Text('Decrypt'),
            ),
            SizedBox(height: 10),
            Text(
              'Decrypted text: $_decryptedText',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _onTextChanged(String text) {
    setState(() {
      _isDecryptButtonEnabled = text.isNotEmpty;
      _encryptedText = '';
      _decryptedText = '';
      _errorText = null;
    });
  }

  void _encryptText(String text) {
    try {
      if (text.isNotEmpty) {
        final encrypter = encrypt.Encrypter(
          encrypt.AES(_key, mode: encrypt.AESMode.ecb),
        );
        final encrypted = encrypter.encrypt(text);
        setState(() {
          _encryptedText = encrypted.base64;
        });
      } else {
        print('Text to encrypt cannot be empty');
        //Tambahkan pesan yang sesuai jika teks kosong
      }
    } catch (e, stackTrace) {
      print('Error encrypting text: $e, stackTrace: $stackTrace');
      //Penanganan kesalahan yang sesuai
    }
  }

  void _decryptText(String text) {
    try {
      if (text.isNotEmpty) {
        final encrypter = encrypt.Encrypter(encrypt.AES(_key));
        final decrypted = encrypter.decrypt64(text, iv: iv);

        setState(() {
          _decryptedText = decrypted;
        });
      } else {
        print('Text to decrypt cannot be empty');
      }
    } catch (e, stackTrace) {
      print('Error decrypting text: $e, stackTrace: $stackTrace');
    }
  }
}


void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignInScreen(),
    );
  }
}
  
class SignUpScreen extends StatelessWidget{
final TextEditingController _usernameController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();
final Logger _logger = Logger();
 SignUpScreen({super.key}); 
 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar( 
        title: const Text('Sign Up'), // Judul halaman 
      ), 
      body: Padding( 
        padding: const EdgeInsets.all(16.0), 
        child: Column( 
          crossAxisAlignment: CrossAxisAlignment.stretch, 
          children: <Widget>[ 
            // Input field untuk username 
            TextField( 
              controller: _usernameController, 
              decoration: const InputDecoration( 
                labelText: 'Username', 
                border: OutlineInputBorder(), 
              ), 
            ), 
            const SizedBox(height: 20), 
            // Input field untuk password 
            TextField( 
              controller: _passwordController, 
              decoration: const InputDecoration( 
                labelText: 'Password', 
                border: OutlineInputBorder(), 
              ), 
              obscureText: true, 
            ), 
            const SizedBox(height: 20), 
            ElevatedButton( 
              onPressed: () { 
                _performSignUp(context); // Tombol Sign Up 
              }, 
              child: const Text('Sign Up'), 
            ), 
          ], 
        ), 
      ), 
    ); 
  } 
 
  // Fungsi untuk melakukan proses sign up 
  void _performSignUp(BuildContext context) { 
    try { 
      final prefs = SharedPreferences.getInstance(); 
 
      _logger.d('Sign up attempt'); 
 
      final String username = _usernameController.text; 
      final String password = _passwordController.text; 
 
      // Memeriksa apakah username atau password kosong sebelum melanjutkan sign-up 
      if (username.isNotEmpty && password.isNotEmpty) { 
        final encrypt.Key key = encrypt.Key.fromLength(32); 
        final iv = encrypt.IV.fromLength(16); 
 
        final encrypter = encrypt.Encrypter(encrypt.AES(key)); 
        final encryptedUsername = encrypter.encrypt(username, iv: iv); 
        final encryptedPassword = encrypter.encrypt(password, iv: iv); 
 
        _saveEncryptedDataToPrefs( 
          prefs, 
          encryptedUsername.base64, 
          encryptedPassword.base64, 
          key.base64, 
          iv.base64, 
        ).then((_) { 
          Navigator.pop(context); 
          _logger.d('Sign up succeeded'); 
        }); 
      } else { 
        _logger.e('Username or password cannot be empty'); 
      } 
    } catch (e) { 
      _logger.e('An error occurred: $e'); 
    } 
  } 
 
  // Fungsi untuk menyimpan data terenkripsi ke SharedPreferences 
  Future<void> _saveEncryptedDataToPrefs( 
      Future<SharedPreferences> prefs, 
      String encryptedUsername, 
      String encryptedPassword, 
      String keyString, 
      String ivString, 
      ) async { 
    final sharedPreferences = await prefs; 
    // Logging: menyimpan data pengguna ke SharedPreferences 
    _logger.d('Saving user data to SharedPreferences'); 
    await sharedPreferences.setString('username', encryptedUsername); 
    await sharedPreferences.setString('password', encryptedPassword); 
    await sharedPreferences.setString('key', keyString); 
    await sharedPreferences.setString('iv', ivString); 
  } 
} 
 
// Kelas SignInScreen, tampilan untuk proses sign in 
class SignInScreen extends StatelessWidget { 
  final TextEditingController _usernameController = TextEditingController(); 
  final TextEditingController _passwordController = TextEditingController(); 
  final Logger _logger = Logger(); // Untuk logging 
 
  SignInScreen({super.key}); 
 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar( 
        title: const Text('Sign In'), // Judul halaman 
      ), 
      body: Padding( 
        padding: const EdgeInsets.all(16.0), 
        child: Column( 
          crossAxisAlignment: CrossAxisAlignment.stretch, 
          children: <Widget>[ 
            // Input field untuk username 
            TextField( 
              controller: _usernameController, 
              decoration: const InputDecoration( 
                labelText: 'Username', 
                border: OutlineInputBorder(), 
              ), 
            ), 
            const SizedBox(height: 20), 
            // Input field untuk password 
            TextField( 
              controller: _passwordController, 
              decoration: const InputDecoration( 
                labelText: 'Password', 
                border: OutlineInputBorder(), 
              ), 
              obscureText: true, 
            ), 
            const SizedBox(height: 20), 
            // Tombol Sign In 
            ElevatedButton( 
              onPressed: () { 
                _performSignIn(context); 
              }, 
              child: const Text('Sign In'), 
            ), 
            const SizedBox(height: 20), 
            // Tombol untuk pindah ke halaman pendaftaran 
            TextButton( 
              onPressed: () { 
                Navigator.push( 
                  context, 
                  MaterialPageRoute(builder: (context) => SignUpScreen()), 
                ); 
              }, 
              child: const Text('Sign Up'), 
            ), 
          ], 
        ), 
      ), 
    ); 
  } 
 
  // Fungsi untuk melakukan proses sign in 
  void _performSignIn(BuildContext context) { 
    try { 
      final prefs = SharedPreferences.getInstance(); 
 
      final String username = _usernameController.text; 
      final String password = _passwordController.text; 
      _logger.d('Sign in attempt'); 
 
      if (username.isNotEmpty && password.isNotEmpty) { 
        _retrieveAndDecryptDataFromPrefs(prefs).then((data) { 
          if (data.isNotEmpty) { 
            final decryptedUsername = data['username']; 
            final decryptedPassword = data['password']; 
 
            if (username == decryptedUsername && password == decryptedPassword) { 
              Navigator.pushReplacement( 
                context, 
                MaterialPageRoute(builder: (context) => const HomeScreen()), 
              ); 
              _logger.d('Sign in succeeded'); 
            } else { 
              _logger.e('Username or password is incorrect'); 
            } 
          } else { 
            _logger.e('No stored credentials found'); 
          } 
        }); 
      } else { 
        _logger.e('Username and password cannot be empty'); 
        // Tambahkan pesan untuk kasus ketika username atau password kosong 
      } 
    } catch (e) { 
      _logger.e('An error occurred: $e'); 
    } 
  } 
 
  // Fungsi untuk mengambil dan mendekripsi data dari SharedPreferences 
  Future<Map<String, String>> _retrieveAndDecryptDataFromPrefs( 
      Future<SharedPreferences> prefs, 
      ) async { 
    final sharedPreferences = await prefs; 
    final encryptedUsername = sharedPreferences.getString('username') ?? ''; 
    final encryptedPassword = sharedPreferences.getString('password') ?? ''; 
    final keyString = sharedPreferences.getString('key') ?? ''; 
    final ivString = sharedPreferences.getString('iv') ?? ''; 
 
    final encrypt.Key key = encrypt.Key.fromBase64(keyString); 
    final iv = encrypt.IV.fromBase64(ivString); 
 
    final encrypter = encrypt.Encrypter(encrypt.AES(key)); 
    final decryptedUsername = 
    encrypter.decrypt64(encryptedUsername, iv: iv); 
    final decryptedPassword = 
    encrypter.decrypt64(encryptedPassword, iv: iv); 
 
    // Mengembalikan data terdekripsi 
    return {'username': decryptedUsername, 'password': decryptedPassword}; 
  } 
} 
 
// Kelas HomeScreen, halaman utama setelah berhasil sign in 
class HomeScreen extends StatelessWidget { 
  const HomeScreen({super.key}); 
 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar( 
        title: const Text('Home'), // Judul halaman 
      ), 
      body: const Center( 
        child: Text('Welcome!'), // Pesan selamat datang 
      ), 
    ); 
  } 
} 
