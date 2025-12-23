# Contributing to SkillBucket

SkillBucket is a project inspired by, built for, and maintained by, you. below are instructions for how to contribute to SkillBucket, they are general steps with links to more detailed explanations where available.

## Contributing

> ⚠️ SkillBucket uses `develop` as the main integration branch.
> All pull requests should target `develop`, not `main`.


### Step 1: clone the repo

Clone the SkillBucket GitHub repository by running
```bash
git clone git@github.com:ItaiAdd/skill_bucket.git
```
---
### Step 2: switch to the develop branch

Change to the ```develop``` branch by running
```bash
git checkout develop
```
---
### Step 3: create your feature branch

The branch naming convention is ```<TYPE>/<NUMBER>-<DESCRIPTION>``` ([see more here](#Branch-Naming-Conventions)).

```bash
git checkout -b <BRANCH NAME>
```
---
### Step 4: Set up the development environment

The development environment can be set up quickly using [GNU Make](https://www.gnu.org/software/make/) or manually. For a quick setup make sure GNU Make is installed and run

```bash
make setup
```

from the project root directory. Other more fine grained control is available through defined Make workflows (run ```make help``` for more options).

For manual setup details see [Manual Setup Options](#Manual-Setup).

---

### Step 5: make and commit your changes/additions

You can now make your changes. It is a best practice to **commit little changes often** rather than a couple of massive commits. To commit and push changes run the following.

```bash
git add <files/ directories you want to include>
```

or

```bash
git add .
```
to add all changes. **Note: this adds ALL changes to anything not included in the .gitignore file, be careful not to include anything private**.

Once you have added your changes, commit them by running

```bash
git commit -m <short commit message>
```
Commit messages should be short, descriptive, and written in the imperative
 (e.g. "Add skill query endpoint", not "Added skill query endpoint").

 Lastly you can push your changes to a feature branch by running

```bash
git push -u origin <branch name>
```
where the branch name is the one you made earlier (```<TYPE>/<NUMBER>-<DESCRIPTION>```).

### Step 6: make a pull request

Before opening a pull request, please make sure that:

- Tests pass locally (`make test`)
- New functionality includes tests where appropriate
- Documentation is updated if behaviour changes

When you have finalised your contribution, make a pull request (PR) into the ```develop``` branch. There will be templates available for each [contribution type](#TYPE). If your PR fixes, resolves, or closes an issue, please include the relevant keyword (e.g ```Closes #123```).

Resolve any comments left on the PR, and once it’s merged — enjoy the cred 🎉


## Manual Setup
Manual setup instructions will be added soon.
Until then, please use the automated setup via `make setup`.


## Branch Naming Conventions

Branches should be named using the standard format

```<TYPE>/<NUMBER>-<DESCRIPTION>```

### TYPE

The branch type indicates the objective of the work being done such as adding a feature or fixing a bug. The table below shows which ```TYPE``` label to use for different objectives.

TYPE | when to use
--- | ---
```feature``` | Adding new functionality
```bugfix``` | Standard bug fixes
```hotfix``` | Urgent production fix (e.g broken API endpoint)
```docs``` | Adding documentation with no code changes
```tests``` | Adding tests without changes to the core code

### NUMBER
This number links what you did to an initial feature request, bug report or other reason for starting the work you did. The ```NUMBER``` should be one of:

- An issue number from a GitHub issue on the SkillBucket repo.
- A ticket number from the SkillBucket ticket board.

**If you have a feature idea which has not already been made into an issue or ticket please make one before you begin your work.**

### DESCRIPTION
The description should briefly summarise what the point of the work is. The ```DESCRIPTION``` should be snake case and no more than 3 or 4 words and should be as specific as possible. Examples could be:

- utils_unit_tests
- readme_updates
- skill_query_endpoint
- agent_response_error_handling
