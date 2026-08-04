// Ranks letter sizes XXS..XXL in their natural order, then numeric sizes by
// value, with anything unrecognized sorted last. Mirrors the sizeRankCase SQL
// expression in shine_api's dressRepository.ts.
const _letterSizeOrder = ['XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL'];

int sizeRank(String size) {
  final letterIndex = _letterSizeOrder.indexOf(size);
  if (letterIndex != -1) return letterIndex;
  final numeric = int.tryParse(size);
  if (numeric != null) return _letterSizeOrder.length + numeric;
  return _letterSizeOrder.length + 1000;
}
