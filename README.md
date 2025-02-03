# SkillRX
SkillRX is a Ruby on Rails content management application which will allow medical training providers to upload and manage content which will be delivered to Raspberry Pi and other computers in low-resource areas for use by medical professionals at these locations.

The project provides a ground-up rewrite of the [CMES Admin Panel](https://github.com/techieswithoutborders/cmes-admin-panel-next) for [Techies Without Borders](https://techieswithoutborders.us/).

> [CMES](https://cmesworld.org/) is an initiative of Techies without Borders, a global nonprofit focused on harnessing technology for social development. CMES aims to address the difficulty in accessing CME content for medical practitioners in resource-constrained areas of the world, a critical problem in public health. Since its inception in January 2016, the CMES team has distributed over 200 CMES thumb drives to medical doctors and nurses working at remote locations in Nepal, Uganda, Ecuador, Nigeria, St. Lucia and the Oceania region (Fiji,Tonga, Solomon Islands, Tuvalu, Samoa and Cook Islands).

# Ruby for Good
SkillRX is one of many projects initiated and run by Ruby for Good. You can find out more about Ruby for Good at https://rubyforgood.org.

# Welcome Contributors!
Thank you for checking out our work. We are in the process of setting up the repository, roadmap, values, and contribution guidelines for the project. We will be adding issues and putting out a call for contributions soon.


[Contribution guidelines for this project](CONTRIBUTING.md)


# Install & Setup

Clone the codebase 
```
git clone git@github.com:rubyforgood/skillrx.git
``` 

Run the setup script to prepare DB and assets
```sh
bin/setup
```

To run the app locally, use:
```
bin/dev
```

To update dependencies in Gemfile, use:
```
bundle install
```

You should see the seed organization by going to:
```
http://localhost:3000/
```


# Running specs

```sh
# Default: Run all spec files (i.e., those matching spec/**/*_spec.rb)
$ bundle exec rspec

# Run all spec files in a single directory (recursively)
$ bundle exec rspec spec/models

# Run a single spec file
$ bundle exec rspec spec/controllers/accounts_controller_spec.rb

# Run a single example from a spec file (by line number)
$ bundle exec rspec spec/controllers/accounts_controller_spec.rb:8

# See all options for running specs
$ bundle exec rspec --help
```


# Testing

This project uses:
* `rspec` for testing
* `shoulda-matchers` for expectations
* `factory_bot` for making records

To run tests execute
```
bin/rspec
```

