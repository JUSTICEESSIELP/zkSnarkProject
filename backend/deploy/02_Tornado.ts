import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction, DeployedContract } from "hardhat-deploy/types";

const Tonardo: DeployFunction = async function ({
  getNamedAccounts,
  deployments,
  run,
}) {
  // code here
  const { deploy, get } = deployments;
  const { deployer } = await getNamedAccounts();
  const HasherContract = await get("Hasher");

   await deploy("Tornado", {
    from: deployer,
    args: [HasherContract.address],
    log: true,
  });

};
export default Tonardo;

Tonardo.tags = ["Tornado", "all"];
