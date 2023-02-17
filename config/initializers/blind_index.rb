# https://github.com/ankane/blind_index/blob/master/docs/Other-Algorithms.md
# We don't use the default algorithm as it changes specs duration time from 2min to 15min, which is an indicator of
# possible slowness that would occur in production too, although maybe mostly when backfilling the blind indexes.
# This can be changed later, by clearing the blind indexes and running `BlindIndex.backfill(Individual)`.

BlindIndex.default_options = {algorithm: :pbkdf2_sha256}
