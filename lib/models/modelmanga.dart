class ReadImages {
  ReadImages(this.images);

  List<dynamic> images;
}

class ChaptersRead {
  ChaptersRead(this.numberCap, this.title, this.idRelease);

  ChaptersRead.fromJson(Map<String, dynamic> json)
      : numberCap = json['number'],
        title = json['title'],
        idRelease = json['id_release'];
  String numberCap;
  String title;
  int idRelease;
}

class ReadModel {
  ReadModel(this.listImages, this.listChapters);

  ReadImages listImages;
  List<ChaptersRead> listChapters;
}

class ChaptersDetails {
  ChaptersDetails(this.idSerie, this.idChapter, this.nameSerie, this.number,
      this.chapterName, this.date, this.slug);

  ChaptersDetails.fromJson(Map<String, dynamic> json)
      : idSerie = json['id_serie'],
        idChapter = json['id_chapter'],
        nameSerie = json['name'],
        number = json['number'],
        chapterName = json['chapter_name'],
        date = json['date'],
        slug = json['releases'][json['releases'].keys.toList().first]['link'];

  int idSerie;
  int idChapter;
  String nameSerie;
  String number;
  String chapterName;
  String date;
  String slug;
}

class SerieDetails {
  SerieDetails(
      {required this.image,
      required this.ranking,
      required this.title,
      required this.author,
      required this.categories,
      required this.idCategories,
      required this.desc,
      required this.synomTitle,
      required this.score});

  String? image;
  String? ranking;
  String? title;
  String? author;
  List<String?> categories;
  List<String?> idCategories;
  String? desc;
  String? synomTitle;
  String? score;
}

class CategorySeries {
  CategorySeries(
      this.idSerie,
      this.nameSerie,
      this.qtdChapters,
      this.description,
      this.image,
      this.author,
      this.score,
      this.slug,
      this.isComplete);

  CategorySeries.fromJson(Map<String, dynamic> json)
      : idSerie = json['id_serie'],
        nameSerie = json['name'],
        qtdChapters = json['chapters'],
        description = json['description'],
        image = json['cover'],
        author = json['author'],
        score = json['score'],
        slug = json['link'],
        isComplete = json['is_complete'];

  int idSerie;
  String nameSerie;
  int? qtdChapters;
  String? description;
  String image;
  String author;
  String score;
  String slug;
  bool isComplete;
}

class CategoryList {
  CategoryList(this.idCategory, this.name, this.label, this.value,
      this.qtdSeries, this.slug);

  CategoryList.fromJson(Map<String, dynamic> json)
      : idCategory = json['id_category'],
        name = json['name'],
        label = json['label'],
        value = json['value'],
        qtdSeries = json['titles'],
        slug = json['link'];

  int idCategory;
  String name;
  String label;
  String value;
  int qtdSeries;
  String slug;
}

class SearchModel {
  SearchModel({required this.categorys, required this.series});

  List<CategoryList?> categorys;
  List<CategorySeries?> series;
}
