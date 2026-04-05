enum CategoriesHelper {
  nothing,
  basics,
  documents,
  lists;

  String get name {
    switch (this) {
      case CategoriesHelper.nothing:
        return '';
      case CategoriesHelper.basics:
        return 'Básicos';
      case CategoriesHelper.documents:
        return 'Documentos';
      case CategoriesHelper.lists:
        return 'Listas';
    }
  }
}
