/// Binary traits a breed may have.
///
/// The API reports these as `0` or `1`. Mapping them to a type keeps the raw
/// number out of the UI, which labels each trait in the active language and
/// shows only the traits a breed actually has.
enum BreedFlag {
  indoor,
  lap,
  hypoallergenic,
  natural,
  rare,
  rex,
  hairless,
  shortLegs,
  suppressedTail,
  experimental,
}
