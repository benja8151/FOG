const HelloWorld = artifacts.require("HelloWorld");
const Population = artifacts.require("Population");

module.exports = function (deployer) {
    //deployer.deploy(HelloWorld);
    deployer.deploy(Population);
};
