extension TwoDecimal on double {
  String twoDecimal() {
    try {
      var right;
      try {
        right = this.toString().split(".")[1].padRight(2, "0").substring(0, 2);
      } catch (e) {
        right = "00";
      }
      var left = this.toString().split(".")[0];

      double number = double.parse(left + "." + right);
      return number.toStringAsFixed(2);
    } catch (e) {
      return this.toStringAsFixed(2);
    }
  }
}
