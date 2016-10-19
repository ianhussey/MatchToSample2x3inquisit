# One-to-Many Match to Sample Task for Two Three-Member Classes (MTS - OtM 2x3)

## License
### Code

Copyright (c) Ian Hussey 2016 (ian.hussey@ugent.be)

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

### Stimuli

Cartoon characters (pokemon) from [bulbapedia](http://bulbapedia.bulbagarden.net/wiki/List_of_Pok%C3%A9mon_by_National_Pok%C3%A9dex_number), under a [Creative Commons  Attribution-NonCommercial-ShareAlike 2.5 license](https://creativecommons.org/licenses/by-nc-sa/2.5/). 

## Version
0.1

Written in Inquisit 4.0.0.9

## Notes
- Trains two three-member classes: A1-B1-C1 and A2-B2-C2 via one-to-many match to sample training; then assesses for emergent C-B and B-C (equivalence) relations.
- Includes R script in the "Analysis" folder which produces summaries of MTS performances, including demographic variables, pass/fail variables for both training and testing phases, and how many cycles of each were needed.

## Task structure
*See the 'Explanation of task parameters' folder for illustrations of the task structure and the variables in the excel files that determine your parameters.*

- Training Phase 1:
  - A1-B1 and A2-B2
  - 16 trials
  - up to 5 blocks
  - ends after 5 blocks or when mastery criterion is met (>=14/16 trials correct in a block).
- TrainingPhase 2:
  - A1-C1 and A2-C2
  - 16 trials
  - up to 5 blocks
  - ends after 5 blocks or when mastery criterion is met (>=14/16 trials correct in a block).
- Training Phase 3:
  - A1-B1, A2-B2, A1-C1 and A2-C2
  - 16 trials
  - up to 5 blocks
  - ends after 5 blocks or when mastery criterion is met (>=14/16 trials correct in a block).
- Testing Phase:
  - B1-C1, B2-C2
  - 16 trials
  - 1 block
  - Mastery criterion of 14/16 trials correct (set by R processing file)

## Known issues
None.

## To do
- None

## Changelog
### 0.1 

Successful piloted on prolific academic. c.60% pass rate.