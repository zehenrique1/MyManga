import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:mymanga/models/modelmanga.dart';

Map<String, String> headers = {
  'user-agent':
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36',
  'x-requested-with': 'XMLHttpRequest',
  'Accept-Encoding': 'gzip',
  'authority': 'mangalivre.net'
};

class Read {
  Future<ReadModel?> get(String slug, int release, String number) async {
    Uri url =
        Uri.parse('https://mangalivre.net/ler/$slug/online/$release/$number');
    http.Response response = await http.get(url);
    ReadImages? images = await getImages(response.body, release);
    List<ChaptersRead>? chapters = getChapters(response.body);
    if (images == null || chapters == null) {
      return null;
    }
    return ReadModel(images, chapters);
  }

  Future<ReadImages?> getImages(
    String body,
    int release,
  ) async {
    dom.Document htm = parse(body);
    List<dom.Element> scripts = htm.getElementsByTagName("script");
    String? token;

    for (int i = 0; i < scripts.length; i++) {
      if (scripts[i].text.toString().contains('window.READER_TOKEN =')) {
        token = scripts[i]
            .text
            .toString()
            .split(';')[2]
            .replaceAll('window.READER_TOKEN = ', '')
            .replaceAll("'", '')
            .trim();
      }
    }

    if (token == null) {
      return null;
    }
    Uri imgUrl = Uri.https(
        'mangalivre.net', 'leitor/pages/$release.json', {'key': token});
    http.Response images = await http.get(imgUrl);
    return ReadImages(json.decode(images.body)['images']);
  }

  // GET A LIST OF CHAPTERS
  List<ChaptersRead>? getChapters(String body) {
    List<dom.Element> scripts = parse(body).getElementsByTagName("script");
    for (int i = 0; i < scripts.length; i++) {
      if (scripts[i].text.toString().contains('var chapters = ')) {
        List<dynamic> ctsJson = json.decode(scripts[i]
            .text
            .split(';')[1]
            .replaceAll('var chapters =', '')
            .trim());
        return ctsJson.map((e) => ChaptersRead.fromJson(e)).toList();
      }
    }
    return null;
  }
}

class Details {
  Future<SerieDetails?> getDetails(int idserie) async {
    http.Response response = await http.get(
        Uri.parse('https://mangalivre.net/manga/id/$idserie'),
        headers: headers);
    dom.Element? body = parse(response.body).getElementById('series-data');
    if (body == null) {
      return null;
    }

    return SerieDetails(
        image: body.getElementsByClassName('cover')[1].attributes['src'],
        ranking: body
            .getElementsByClassName('nviews')[0]
            .text
            .trim()
            .replaceAll('#', ''),
        title: body.getElementsByClassName('series-title')[0].text.trim(),
        author: body
            .getElementsByClassName('series-author')[0]
            .text
            .split('\n')[1]
            .replaceAll('  ', ''),
        categories: body
            .getElementsByClassName('touchcarousel-item')
            .map((e) => e.text.trim())
            .toList(),
        idCategories: body
            .getElementsByClassName('touchcarousel-item')
            .map((e) => e.children[0].attributes['href']!.split('/').last)
            .toList(),
        desc: body
            .getElementsByClassName('series-desc')[0]
            .text
            .split('\n')[1]
            .trim(),
        synomTitle: body
            .getElementsByClassName('series-synom')[0]
            .text
            .trim()
            .replaceAll('  ', '')
            .replaceAll('\n', ', '),
        score: body.getElementsByClassName('score-number')[0].text.trim());
  }

  Future<List<ChaptersDetails>?> getChapters(int page, int idserie) async {
    http.Response response = await http.get(
        Uri.parse(
            'https://mangalivre.net/series/chapters_list.json?page=$page&id_serie=$idserie'),
        headers: headers);
    try {
      List<dynamic> jsonChapters = jsonDecode(response.body)['chapters'];
      return jsonChapters.map((e) => ChaptersDetails.fromJson(e)).toList();
    } catch (e) {
      return null;
    }
  }
}

class Category {
  Future<List<CategorySeries>?> get(int idCategory, int page) async {
    http.Response response = await http.get(
        Uri.parse(
            'https://mangalivre.net/categories/series_list.json?page=$page&id_category=$idCategory'),
        headers: headers);
    try {
      List<dynamic> jsonSeries = jsonDecode(response.body)['series'];
      return jsonSeries.map((e) => CategorySeries.fromJson(e)).toList();
    } catch (e) {
      return null;
    }
  }
}

class ListCategory {
  Future<List<CategoryList>?> getSimple() async {
    http.Response response = await http.get(
        Uri.parse('https://mangalivre.net/categories/categories_list.json'),
        headers: headers);
    try {
      List<dynamic> jsonListCategory =
          jsonDecode(response.body)['categories_list'];
      return jsonListCategory.map((e) => CategoryList.fromJson(e)).toList();
    } catch (e) {
      return null;
    }
  }

// CATEGORY WITH SERIES
// void getDetails() async{
//   https://mangalivre.net/categories/categories_series_list.json
// }
}

class Search {
  Future<SearchModel?> get(String data) async {
    http.Response response = await http.post(
        Uri.parse('https://mangalivre.net/lib/search/series.json'),
        headers: headers,
        body: {'search': data});
    try {
      Map<String, dynamic> jsonSearch = jsonDecode(response.body);
      List<dynamic> C = jsonSearch['categories'];
      List<dynamic> S = jsonSearch['series'];
      return SearchModel(
          categorys: C.map((e) => CategoryList.fromJson(e)).toList(),
          series: S.map((e) => CategorySeries.fromJson(e)).toList());
    } catch (e) {
      return null;
    }
  }
}

class MostReadPeriod {
  Future<List<MostReadPeriodSerie>?> get(
      {String type = '', String period = 'week'}) async {
    http.Response response = await http.get(
        Uri.parse(
            'https://mangalivre.net/home/most_read_period?period=$period&type=$type'),
        headers: headers);
    try {
      List<dynamic> jsonMostRead = json.decode(response.body)['most_read'];
      return jsonMostRead.map((e) => MostReadPeriodSerie.fromJson(e)).toList();
    } catch (e) {
      return null;
    }
  }
}

class Featured {
  Future<List<FeaturedSerie>?> get() async {
    http.Response response = await http.get(
        Uri.parse('https://mangalivre.net/home/getFeaturedSeries.json'),
        headers: headers);
    try {
      List<dynamic> jsonFeatured = json.decode(response.body)['featured'];
      return jsonFeatured.map((e) => FeaturedSerie.fromJson(e)).toList();
    } catch (e) {
      return null;
    }
  }
}

class Releases {
  Future<List<ReleaseSerie>?> get({int page = 1, String type = ''}) async {
    http.Response response = await http.get(
        Uri.parse('https://mangalivre.net/home/releases?page=$page&type=$type'),
        headers: headers);
    try {
      List<dynamic> jsonReleases = jsonDecode(response.body)['releases'];
      return jsonReleases.map((e) => ReleaseSerie.fromJson(e)).toList();
    } catch (e) {
      return null;
    }
  }
}

class MostRead {
  Future<List<MostReadSerie>?> get({int page = 1, String type = ''}) async {
    http.Response response = await http.get(
        Uri.parse(
            'https://mangalivre.net/home/most_read?page=$page&type=$type'),
        headers: headers);
    try {
      List<dynamic> jsonMostRead = json.decode(response.body)['most_read'];
      return jsonMostRead.map((e) => MostReadSerie.fromJson(e)).toList();
    } catch (e) {
      return null;
    }
  }
}

class NewSeries {
  Future<List<FinishedNewSerie>?> get({String type = ''}) async {
    http.Response response = await http.get(
        Uri.parse('https://mangalivre.net/home/getNewSeries?type=$type'),
        headers: headers);
    try {
      List<dynamic> jsonNewSeries = json.decode(response.body)['new_series'];
      return jsonNewSeries.map((e) => FinishedNewSerie.fromJson(e)).toList();
    } catch (e) {
      return null;
    }
  }
}

class FinishedSeries {
  Future<List<FinishedNewSerie>?> get({String type = ''}) async {
    http.Response response = await http.get(
        Uri.parse('https://mangalivre.net/home/getFinishedSeries?type=$type'),
        headers: headers);
    try {
      List<dynamic> jsonFinishedSeries =
          json.decode(response.body)['finished_series'];
      return jsonFinishedSeries
          .map((e) => FinishedNewSerie.fromJson(e))
          .toList();
    } catch (e) {
      return null;
    }
  }
}
