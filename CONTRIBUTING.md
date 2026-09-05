# Contributing to Project

Thank you for contributing to the project. Your contributions will help us take the project to the next level.

This project adheres to the Contributor Covenant code of conduct. Your contribution implies that you have read and agree to this policy. Any behavior that undermines the quality of the project community, including this policy, will be warned or restricted by the maintainers.

## Issues

Issues can be created on the following page: https://github.com/jooy2/plass-ui/issues

Alternatively, you can email the package maintainer. However, we prefer to track progress via GitHub Issues.

When creating an issue, keep the following in mind:

- Please specify the correct category selection based on the format of the issue (e.g., bug report, feature request).
- Check to see if there are duplicate issues.
- Describe in detail what is happening and what needs to be fixed. You may need additional materials such as images or video.
- Use appropriate keyword titles to make it easy for others to search and understand.
- Please use English in all content.
- You may need to describe the environment in which the issue occurs.

## Where things live

The repository holds one design language and three things built out of it:

| Path | What it is | How it is run |
| --- | --- | --- |
| `packages/react` | The npm package, `plass-ui` | `cd packages/react && npm install`, then `npm test`, `npm run lint`, `npm run build` |
| `packages/flutter` | The pub.dev package, `plass_ui` | `cd packages/flutter && flutter pub get`, then `flutter test`, `flutter analyze` |
| `docs` | The documentation site, shared by both | `cd docs && npm install`, then `npm run dev` |

There is no install at the repository root, and no root `package.json`. Each of the three is entered and run on its own.

A few notes that are easy to trip over:

- The Flutter previews on the documentation site are the real package compiled for the web. `cd docs && npm run flutter:demos` builds them into `docs/public/flutter`, which is git-ignored; without it the previews say so rather than rendering something misleading.
- The Dart in the documentation is quoted straight out of `packages/flutter/example/lib/demos/`, so a snippet in the docs is code the analyser has checked. Change the demo, not the Markdown.
- A change to a component usually means a change to its page in **both** `docs/en` and `docs/ko`, and to the props table in `docs/.vitepress/data/`.
- A component that exists in both packages should say the same things on one page, with `::: fw react` / `::: fw flutter` around only the parts that genuinely differ, and anything that differs should say why.

## How to contribute (Pull Requests)

### Write the code you want to change

Here's the process for contributing to the project:

1. Clone the project (or rebase to the latest commit in the main branch)
2. Install the package (if the package manager exists)
3. Setting up lint or code formatter in the IDE (if your project includes a linter) and installing the relevant plugins. Some projects may use specific commands to check rules and perform formatting after module installation and before committing.
4. Write the code that needs to be fixed
5. Update the documentation (if it exists) or create a new one. If your project supports multilingual documentation, update the documentation for all languages. You can fill in the content in your own language and not translate it.
6. Add or modify tests as needed (if test code exists). You should also verify that existing tests pass.

### Write a commit message

While we don't have strict restrictions on commit messages, we recommend that you follow the recommendations below whenever possible:

- Write in English.
- Use the ` symbol to name functions, variables, or folders and files.
- Use a format like `xxx: message (fixes #1)`. The content in parentheses is optional.
- The message includes a summary of what was modified.
- It's a good idea to separate multiple modifications into their own commit messages.

It is recommended that you include a tag at the beginning of the commit message. Between the tag and the message, use `: ` between the tag and the message.

tags conform to the ["Udacity Git Commit Message Style Guide"](https://udacity.github.io/git-styleguide). However, you are welcome to use tags not listed here for additional situations.

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Changes to documentation
- `style`: Formatting, missing semicolons, etc.; no code change
- `refactor`: Refactoring production code
- `test`: Adding tests, refactoring test; no production code change
- `chore`: Updating build tasks, package manager configs, etc.; no production code change

Informal tags:

- `package`: Modifications to package settings, modules, or GitHub projects
- `typo`: Fix typos

### Create a pull request

When creating a pull request, keep the following in mind:

- Include a specific description of what the modification is, why it needs to be made, and how it works.
- Check to see if there are duplicate pull requests.
- Please use English in all content.

Typically, a project maintainer will review and test your code before merging it into the project. This process can take some time, and they may ask you for further edits or clarifications in the comments.
