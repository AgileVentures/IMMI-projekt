#How to use I18n to localize SHF

For all text the user will see: any text in views, menus, etc.,
replace the text  with a call to the `t` method.  This is short for `I18n.t` which is provided in Rails.

**There is a Ruby on Rails guide all about I18n:**  http://guides.rubyonrails.org/i18n.html
It starts with information about how to set up the infrastructure in your Ruby on Rails app.
Later it talks about how to use I18n to display text.  

The set up and infrastructure is already in place in SHF
(see the Github PR 85: https://github.com/AgileVentures/shf-project/pull/85).

Getting your application in shape so it can handle different locales/languages is properly called _internationalization_ (aka “**i18n**” -- because there are 18 letters between the “i” and “n”).

What we need now and going forward is to replace all text with calls to `t()` and to use `t()` everywhere going forward.
Having your application show the right language and information for a particular locale is properly called _localization_ (aka “**l10n**”).

This is actually most important because **it makes feature descriptions and specifications (a.k.a integration and unit tests) less brittle.**  We can make changes to the text that a user sees -- which doesn't affect any logic, of course -- without breaking any tests!  (Here's a little write-up about that:   https://robots.thoughtbot.com/better-tests-through-internationalization)

Start by reading this section in guide about l10n, or how to use I18n once the infrastructure is in place:
http://guides.rubyonrails.org/i18n.html#internationalization-and-localization
(You can refer to other info previously presented in the guide if needed, but this is a good, less technical, place to start.)

The gem `i18n-tasks` will look through all of your code  to see if there are any translations that are missing from a .yml file: https://github.com/glebm/i18n-tasks
  It does _not_ check to see what still needs to be localized.  It can’t really know that.

Install the gem on your local system (ex:  `gem install i18n-tasks` )
Make sure you’re in the folder for your project, then
run the i18n-tasks command to see if there are any translations that exist in one locale file but are missing from the other:

`your command prompt ~/shf-project>  ` **`i18n-tasks missing`**

`i18n-task health` is another good command.  Run and look at the documentation for i18n-tasks for more info. `i18n-tasks --help` to see all commands.


## How to replace text in a menu (localizing a menu entry)

Say you want to localize this text in `app/views/application/_navigation.html.haml` :
```
  - if current_user.has_company?
    %li.menu-item.menu-item-has-children
      = link_to 'Hantera företag', company_path(current_user.shf_application.company)
      %ul.sub-menu
       %li.menu-item
          = link_to 'Visa företagssida', company_path(current_user.shf_application.company)
       %li.menu-item
          = link_to 'Redigera företag', edit_company_path(current_user.shf_application.company) 
 ```

This part of the menu is for a _user_ that has a **company.**

We want to take the text `Visa företagssida` and replace it with a call to `t()` that looks up the value in a locale file.  
Since this about a **company**, the keys for these should be somewhere under a ‘company’ key in the locale files.
(We’d want to also replace `Redigera företag`.  After reading through this example, you should be able to do that, too.)

All of the keys referred to in this example will exist under the key for the appropriate locale (ex: `sv:` or `en:`)  
`I18n` takes care of prepending all of the references with the locale key (ex: `sv.errors.messages.blank` or `en.companies.new.title`). That’s why I don’t refer to the locale key in the example below.

1. Make sure an entry for `Visa företagssida` exists in all of the locale files

   Using your favorite editor, search _all_ of the locale files for the text `Visa företagssida`

   1. If the text **is not found** then you need to add it:
      1. A good key for this is `companies.view_company`.  Make an entry in a locale file

          ```
          companies:
            view_company: Visa företagssida
          ```

   2. If the text **is found**, then you need to refer to it (using YML anchors and aliases):
      1. If it uses a key that **_does_** relate to the menu, then use that key.
         1. Ex: Say that you found the text as the value of the key `companies.edit_company`
         So you need to replace the text `Visa företagssida` with `t(‘companies.edit_company')` in the tests and in the menu. (See the section **Now fix the tests** below.)
      2. if it uses a key that **_does not_** relate to that menu, then you need to make an entry
       and *refer* to the value. **Do Not** put the text in again in a locale file.  That’s not DRY!  
        Ex:  Say that you found `Visa företagssida` in the locale files with the key `bad_location.for.view.company`

         1. Make the original value a YAML anchor (if it isn’t already).  Say that the original line looks like this:          

             `bad_location.for.view.company: Visa företagssida `  
             1. Create an anchor named `view_company` in the original line by replacing the _value_ part (after the ‘:’) with this: `&view_company Visa företagssida`
             2. Now the line should look like this:

                `bad_location.for.view.company: &view_company Visa företagssida`
         4. Make an entry in a locale file in the place is appropriate for your menu.  Put in the alias `*view_company` which will refer back to the anchor (`&view_company`):
            1.  Say we want to put the entry in to the locale files using the key `companies.edit_company`.  The line should look like this:

                ```
                companies:
                  view_company: *view_company
                ```
    2. If needed, make entries in **all** of the locale files, translating as necessary.
    Ex: If you made an entry in `config/locales/sv.yml`, you need to copy that and put it into _the exact same place_ in `config/locales/en.yml` -- but obviously use the English translation as the value.

2. Now fix the tests.  Ensure they run **red**.
    1. Search in the integration tests (the cucumber features) and replace any references to `Visa företagssida` with `t(“companies.edit_company”)`.
     Note that you need to use the **double quote** to surround the whole key.  
     There are steps that can look up `I18n.t` information; they expect the **double quotes.**  (You can browse the features and steps for examples of where `t()` can be used. If you need a step to use `t()` but can’t find an appropriate one, speak up on Slack.)
    2. Run the tests -- the should be **red** for any place that references `Visa företagssida`.  

       That proves that you’ve updated the tests correctly, and will also point you to places where `Visa företagssida` is used.  (If there is not a test that refers to that text specifically, then consider if there needs to be one and write it if necessary.)
1. Now replace the text in the code
   1. In `_navigation.html.haml`, replace `Visa företagssida` with `t(‘companies.edit_company’)`
2. Run the tests again.  They should be **green**.
Once you’ve made your changes, make sure that you’re not missing something in a locale file: run

   `i18n-tasks missing`

  5. Run rake to run all tests and ensure they’re green.

Give yourself a high-five!

Repeat for all other text that needs l10n.

## To replace text in a view:  
Be sure to read the RoR I18n guide about **ActiveRecords**.  
That tells you how and why the locale files are organized in a particular way, and how `I18n.t()` will try to look up information in the locale files using particular keys (the convention used).
(You can use a shorthand in the views and let `I18n` find the key using the conventions.)
