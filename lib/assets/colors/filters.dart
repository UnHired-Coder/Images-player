class MatrixFilter {

List<double> mat;
String name;

  MatrixFilter({List<double> mat, String name}){
    this.mat = mat;
    this.name = name;
  }
}

class MatrixFiltersController{

  List<MatrixFilter> filters= [];

  List<double>  SEPIA_MATRIX = [0.39, 0.769, 0.189, 0.0,
    0.0, 0.349, 0.686, 0.168,
    0.0, 0.0, 0.272, 0.534, 0.131,
    0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];

  List<double>  GREYSCALE_MATRIX = [0.2126, 0.7152, 0.0722, 0.0, 0.0,
    0.2126, 0.7152, 0.0722, 0.0, 0.0,
    0.2126, 0.7152, 0.0722, 0.0, 0.0,
    0.0, 0.0, 0.0, 1.0, 0.0];

  List<double>  VINTAGE_MATRIX = [0.9, 0.5, 0.1, 0.0, 0.0,
    0.3, 0.8, 0.1, 0.0, 0.0,
    0.2, 0.3, 0.5, 0.0, 0.0,
    0.0, 0.0, 0.0, 1.0, 0.0];

  List<double>  FILTER_1 = [1.0, 0.0, 0.2, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 1.0, 0.0];

  List<double>  FILTER_2 = [0.4, 0.4, -0.3, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 1.2, 0.0, 0.0,
    -1.2, 0.6, 0.7, 1.0, 0.0];

  List<double>  FILTER_3 = [0.8, 0.5, 0.0, 0.0, 0.0,
    0.0, 1.1, 0.0, 0.0, 0.0,
    0.0, 0.2, 1.1, 0.0, 0.0,
    0.0, 0.0, 0.0, 1.0, 0.0];

  List<double>  FILTER_4 = [1.1, 0.0, 0.0, 0.0, 0.0,
    0.2, 1.0, -0.4, 0.0, 0.0,
    -0.1, 0.0, 1.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 1.0, 0.0];

  List<double>  FILTER_5 = [1.2, 0.1, 0.5, 0.0, 0.0,
    0.1, 1.0, 0.05, 0.0, 0.0,
    0.0, 0.1, 1.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 1.0, 0.0];

  MatrixFiltersController(){
    filters.add(new MatrixFilter(mat: SEPIA_MATRIX, name: "SEPIA"));
    filters.add(new MatrixFilter(mat: GREYSCALE_MATRIX, name: "GREYSCALE"));
    filters.add(new MatrixFilter(mat: VINTAGE_MATRIX, name: "VINTAGE"));
    filters.add(new MatrixFilter(mat: FILTER_1, name: "FILTER_1"));
    filters.add(new MatrixFilter(mat: FILTER_2, name: "FILTER_2"));
    filters.add(new MatrixFilter(mat: FILTER_3, name: "FILTER_3"));
    filters.add(new MatrixFilter(mat: FILTER_4, name: "FILTER_4"));
    filters.add(new MatrixFilter(mat: FILTER_5, name: "FILTER_5"));
  }

  MatrixFilter getFilter(idx){ print(this.filters[idx].toString()); return this.filters[idx];}
}


//ANDROID CODE
// private Bitmap setColorFilter(Bitmap drawable) {
//   Bitmap grayscale  = Bitmap.createBitmap(drawable.getWidth(), drawable.getHeight(), drawable.getConfig());
//   //if(isRenderMode) bOriginal.recycle();
//   Canvas c = new Canvas(grayscale );
//   Paint p = new Paint();
//
//   final ColorMatrix matrixA = new ColorMatrix();
//   matrixA.setSaturation(saturationValue/2);
//
//
//   float[] mx = {
//     r1Value,  r2Value,  r3Value,  r4Value,  r5Value,
//     g1Value,  g2Value,  g3Value,  g4Value,  g5Value,
//     b1Value,  b2Value,  b3Value,  b4Value,  b5Value,
//     a1Value,  a2Value,  a3Value,  a4Value,  a5Value
//   };
//   final ColorMatrix matrixB = new ColorMatrix(mx);
//
//   matrixA.setConcat(matrixB, matrixA);
//
//   final ColorMatrixColorFilter filter = new ColorMatrixColorFilter(matrixA);
//   p.setColorFilter(filter);
//   c.drawBitmap(drawable, 0, 0, p);
//   return grayscale;
// }