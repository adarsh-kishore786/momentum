# Contributing to Momentum

Thanks for taking the time to contribute!

> If you like the project, but just don't have time to contribute, that's fine. 
  There are other easy ways to support the project and show your appreciation,
  which we would also be very happy about:
> - Star the project
> - Tweet about it
> - Refer this project in your project's readme
> - Mention the project at local meetups and tell your friends/colleagues

## Contributing guidelines

Before sending a PR, make sure to raise an issue on the repository. Once the 
issue is approved, you can work on it (see `Project setup` below for instructions),
and submit a PR. The PR should be linked to the issue.

PRs with no issue will be **closed**.

## Project setup

1. Fork this repo, and on your local fork, create a new branch.
2. Branch names must be descriptive, and should follow this convention:
    1. New features should have branches named as `feature/xyz`, eg: `feature/send-notification`
    2. Branches which remove a bug should be `bug/xyz`, eg: `bug/remove-database-error`
3. Flutter must be installed on your system. Check `flutter --version`
4. Get the project dependencies with `flutter pub get`

## PR guidelines

You should test your changes thoroughly to make sure that they do not break
any existing functionality.

Feature PR should contain screenshots or even better, a video recording of the
new feature.
