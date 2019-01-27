This project was bootstrapped with [Create React App](https://github.com/facebook/create-react-app).


## Before You Start
If you run into jquery, popper.js, and resolve-url-loader, you need to install the dependencies with npm.
```
npm install bootstrap
npm install jquery
npm install popper.js
npm install resolve-url-loader
```

### LocalStoage
Instead off using database to store some contract state, the web app use local storage. LocalStorage used by the web app is allowed by default, if you have some special setting preventing it, please temporary allow during evaluation.

![](public/img/md_localstorage.png?raw=true)

### Ganache
Please makesure Ganache is started with the default settings as shown below. Truffle config is configured to connect to Ganache for contract migration.
![](public/img/md_ganache.png?raw=true)

### Metamask 
Makesure you have Metamask Chrome extension installed and configure to connect to the local Ganache Network as shown below
![](public/img/md_metamask_config.png?raw=true)

To evaluate the application properly, it needs several accounts to act as owner (broker/admin), borrower, and lenders. Import the Ganache test accounts to the Metamask by using its private key.
![](public/img/md_metamask_accounts.png?raw=true)

You can switch account while the web app is running, it will refresh the page and use the current selected Metamask account.

## Available Scripts

In the client directory, you can run:

### `npm start`

Runs the app in the development mode.<br>
Open [http://localhost:3000](http://localhost:3000) to view it in the browser.

The page will reload if you make edits.<br>
You will also see any lint errors in the console.



