# vu-drafting
A simple and configurable drafting script I made as practice.

  Entirely configurable.
  
  Standalone with no dependancies.

## How to use

  Drive behind a car moving in the same direction as you to get a speed boost.

  The more centered you are behind the lead car, the more boost you get.
  
  Lead car must be traveling faster than `1-(1/Config.DraftingMultiplier)`times  your current speed. This is to prevent drafting off of significantly slower cars.
## Known issues/ FAQ

#### DraftingMaxDistance doesn't work past 35/40/45 etc.

This is a limitation that comes from how raycasting works on fivem. I have not experimented enough to find the limit.

#### Why didn't you use `SetEnableVehicleSlipstreaming`?

I made this as a practice in using raycasts. I didn't even search for this native until after finishing.

#### Why didn't you just edit the `fInitialDragCoeff` using `SetHandlingFloat`?

See above.
