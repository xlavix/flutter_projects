import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contoh Navigasi 3 Halaman',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Daftar halaman yang akan ditampilkan
  final List<Widget> _pages = [
    HalamanUtama(),
    HalamanHariLibur(),
    HalamanProfile(),
  ];

  final List<String> _titles = [
    'Halaman Utama',
    'Daftar Hari Libur Nasional',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]), // judul dinamis berdasarkan halaman aktif
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Utama'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Hari Libur'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Halaman Utama
class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  _HalamanUtamaState createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Jumlah angka sekarang:', style: TextStyle(fontSize: 18)),
          Text('$_counter', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _decrementCounter,
                child: Icon(Icons.remove),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _incrementCounter,
                child: Icon(Icons.add),
              ),
            ],
          )
        ],
      ),
    );
  }
}


// Halaman Hari Libur
class HalamanHariLibur extends StatefulWidget {
  const HalamanHariLibur({super.key});

  @override
  _HalamanHariLiburState createState() => _HalamanHariLiburState();
}

class _HalamanHariLiburState extends State<HalamanHariLibur> {
  List hariLibur = [];
  bool loading = true;

  Future<void> fetchHariLibur() async {
    setState(() {
      loading = true;
    });

    final response = await http.get(Uri.parse('https://api-harilibur.vercel.app/api'));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);

      // Koreksi format tanggal sebelum sorting
      data.sort((a, b) {
        DateTime tanggalA = parseTanggal(a['holiday_date']);
        DateTime tanggalB = parseTanggal(b['holiday_date']);
        return tanggalA.compareTo(tanggalB);
      });

      setState(() {
        hariLibur = data;
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

// Fungsi tambahan untuk memperbaiki format tanggal
  DateTime parseTanggal(String tanggal) {
    final parts = tanggal.split('-');
    final tahun = parts[0];
    final bulan = parts[1].padLeft(2, '0');
    final hari = parts[2].padLeft(2, '0');
    return DateTime.parse('$tahun-$bulan-$hari');
  }


  @override
  void initState() {
    super.initState();
    fetchHariLibur();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Daftar Hari Libur Nasional Indonesia (${DateTime.now().year})',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          DataTable(
            columns: [
              DataColumn(label: Text('Tanggal')),
              // DataColumn(label: Text('Hari')),
              DataColumn(label: Text('Keterangan')),
            ],
            rows: hariLibur
                .map((libur) => DataRow(cells: [
              DataCell(Text(libur['holiday_date'] ?? '')),
              // DataCell(Text(libur['day_name'] ?? '')),
              DataCell(Text(libur['holiday_name'] ?? '')),
            ]))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// Halaman Profile (menggantikan halaman dua)
class HalamanProfile extends StatelessWidget {
  const HalamanProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12), // Rounded corner
              child: SizedBox(
                width: 120,    // lebar 3
                height: 160,   // tinggi 4 (rasio 3:4)
                child: Image.asset(
                  'assets/images/avatar.jpeg', // Pastikan nama file sama persis
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text('Nama:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Didik Soecipto', style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          Text('Tempat, Tanggal Lahir:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Jakarta, 24 Februari 1990', style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          Text('Alamat:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Jl. Sudirman No. 123, Jakarta', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
