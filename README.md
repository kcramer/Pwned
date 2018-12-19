# Pwned

[![CI Status](https://img.shields.io/travis/com/kcramer/Pwned.svg?style=flat)](https://travis-ci.com/kcramer/Pwned)

Pwned uses the [Have I Been Pwned?](https://haveibeenpwned.com/) database created by 
security researcher Troy Hunt.  When sites are hacked, any public information about the 
accounts and passwords included in that breach are added to this database. It can include 
user names, email addresses, passwords, and more.

You can use Pwned to check if your account or passwords have been a part of a data breach. 
If so, change your passwords for the relevant accounts and do not reuse that password.

![Screenshot - Account Search](/images/Screenshot-AccountSearch.png) ![Screenshot - Password Result](/images/Screenshot-PasswordResult.png)

## Privacy

When you search for breaches by account, Pwned sends your account name / email to
the Have I Been Pwned? database to get the results.  Your recent searches are stored
to make it easier to check them again.  You can clear that list at any time.

When you search for a password, for security reasons the Pwned app does not send your 
actual password.  It creates a cryptographic hash of your password.  The hash is a one way 
conversion that turns your password into a string of fourty characters.  The first five characters 
only are sent to the service which returns all the possible matches.  The Pwned app then 
chooses the right one and displays the results.

As an example, if you search for **password** it is converted into:

    5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8

Only the first five characters **5baa6** are sent to the service.  Hundreds of possibilities are 
returned.  The app picks the one that has the correct match for the full fourty character hash 
and displays the count to you.

Your password does not leave the device nor is it saved on your device.  It is only used 
temporarily as described above.
