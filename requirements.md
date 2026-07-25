First we have implemented that lock feature.
Now that lock feature is working but main issue is when i minimize the app
then open the app again and it checks for lock again. 
What i want is, lock the first time, then if the app is running in background or users minimizes
the app then again it should not ask for lock. 

two main condition:
1. cold starts: authenicate on app launch, then mark the session as unlocked

2. Background / inactivity timer: when the app is minimized, start a timer. If the user returns before the timer expires, skip the lock screen. If they return after the timer expire -or 
if they swiped the app away from the recent apps (which terminates the process) - trigger the lock screen again.


step 1: create a lock controller / state manager
create a manager that tracks whether the app is currently authenticated and handles the background timeout logic.


step 2: implement the lock screen wrapper: wrap apps main view or splash screen with a widget that checks isAuthenicated. Because cold starts wipe memory state, launching the app after clearing it from the recent apps automatically starts with _isAuthenticated = false.

step 3: wrap app root: wrap home screen or bottom navigation view with MainGateKeeper