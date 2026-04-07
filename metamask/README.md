### MetaMask Setup Guide: Install, Secure Wallet, Add Arbitrum Sepolia, and Claim Faucet ETH

This guide walks you through installing MetaMask on Chrome, creating and securing your wallet, adding the Arbitrum Sepolia test network, claiming test ETH from a faucet, and copying your public address or exporting a chain private key when you need them. Every step includes a screenshot for quick visual reference.

Note: Never share your Secret Recovery Phrase (SRP) or private keys. Anyone with them can control your funds.

---

## 1) Install MetaMask and Create Your Wallet

1. Open the Chrome Web Store page for MetaMask: [MetaMask – Chrome Web Store](https://chromewebstore.google.com/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn)

   ![MetaMask on Chrome Web Store](./assets/metamask_chrome_store.png)

2. Click Add to Chrome, then confirm to install the extension.

   ![Click Add to Chrome](./assets/add_extension.png)

3. Choose login method and click Continue with Google.

   ![Choose login method](./assets/metamask_choose_login_method.png)

4. Choose your Google account.

   ![Choose your Google account](./assets/metamask_choose_acc.png)

5. Click Continue.

   ![Click Continue](./assets/metamask_continue_click.png)

6. Agree to the terms and conditions and continue.

   ![Agree to the terms and conditions](./assets/agree_terms_conditions.png)

7. Set a strong password and continue.

   ![Create password](./assets/create_password.png)

8. Read the security guidance and continue to reveal your Secret Recovery Phrase (SRP) by clicking the Get started button.

   ![Secure your wallet](./assets/secure_wallet.png)

9. Click Continue again.

   ![Click Continue again](./assets/metamask_continue.png)

10. Now your MetaMask setup is done. Click Open wallet, and MetaMask will appear in the side panel of your browser.

   ![Your wallet is ready](./assets/metamasm_wallet_ready.png)

11. Click the Agree button to agree.

   ![Click Agree](./assets/metamask_click_agree.png)

12. Click the right-side 3-dot menu if you want a pop up behaviour in MetaMask.

   ![Click 3-dot menu](./assets/metamask_3dot.png)

13. Click Switch to popup to change the behaviour.

   ![Switch to popup](./assets/metamask_switch_to_popup.png)

14. MetaMask will appear as a popup (as shown in this screenshot).

   ![MetaMask popup](./assets/metamasm_popup.png)

### Option 2: Sign in with Secret Recovery Phrase (SRP)

1. Click on Continue with Secret Recovery Phrase button.

   ![Continue with SRP](./assets/continue_with_srp.png)

2. Reveal the SRP and store it offline in a safe place by clicking on "Tap to reveal" text. Do not share it with anyone. You can take a screenshot/picture of the SRP to store it offline or else you can write it down on a piece of paper.

   ![Tap to reveal SRP](./assets/tap_to_reveal.png)

   ![Do not share SRP](./assets/do_not_share_this_secret_phrase_with_anyone.png)

***Note : Make sure you stored the SRP in the correct order as it will be used in the next step to confirm the SRP.***

3. Confirm your SRP to finish wallet setup by clicking the missing words in the order of the SRP.

   ![Confirm SRP](./assets/confirm_secret_phrase.png)

4. Help improve MetaMask by sharing usage data (optional).

   ![Help improve MetaMask](./assets/help_improve_metamask.png)

5. You should see a completion screen. Click Done.

   ![Setup done](./assets/done.png)

Optional: If prompted with non-EVM content (e.g., Solana), ignore or close it; MetaMask here is used for EVM chains like Arbitrum.

![Ignore unrelated Solana prompt](./assets/do_not_view_solana_account.png)

---

## 2) Pin and Open the MetaMask Extension


1. Pin MetaMask so it stays visible in your toolbar by clicking on the Extensions Icon and then clicking on the Pin button next to MetaMask extension

   ![Pin the extension](./assets/pin_extension.png)

2. After setup, you can view MetaMask among your extensions.
   
   ![Open pinned extension](./assets/open_pinned_extension.png)
   
3. Then click the MetaMask icon to open it.

    ![View MetaMask as an extension](./assets/view_metamask_as_extension.png)

---

## 3) Add the Arbitrum Sepolia Test Network

You can add the network inside MetaMask. Follow the prompts to add Arbitrum Sepolia and approve it.

1. Go to the Arbitrum Sepolia Explorer - [Arbitrum Sepolia Explorer](https://sepolia.arbiscan.io/) And then scroll down to the footer section and click on the "Add Arbitrum Sepolia Network" button.

   ![Add Arbitrum Sepolia](./assets/add_arbitrum_sepolia_network.png)

2. Approve the network addition when MetaMask asks for confirmation.

   ![Approve network addition](./assets/approve_network_addition.png)

3. Verify that Arbitrum Sepolia is selected in the network dropdown.

   ![Verify network is active](./assets/verify_network.png)

---

## 4) Claim Test ETH on Arbitrum Sepolia (Faucet)

Go to the Lampros DAO Faucet website - [Lampros DAO Faucet](https://faucet.lamprosdao.com/)

1. Open the faucet website and click on the "Connect Wallet" button.

   ![Connect Wallet](./assets/connect_wallet.png)

2. Select the "MetaMask" option.

   ![Select MetaMask](./assets/choose_metamask_as_option.png)

3. Approve the account connection in MetaMask when it prompts by clicking on the Connect button.

    ![Connect account](./assets/connect_account.png)

4. Join the Arbitrum Builder Pod telegram channel to get the latest updates and then click on the "Next" button.

    ![Join Telegram](./assets/arbitrum-builder-pods.png)

5. Complete CAPTCHA verification by clicking on the "I'm not a robot" checkbox.

   ![Complete CAPTCHA](./assets/complete_captcha.png)

6. Click the "Claim 0.01 ETH" button to get 0.01 ETH.

   ![Claim ETH](./assets/claim_eth.png)

7. After a successful request, you should see a confirmation as "Transaction Successful".

   ![Claim success](./assets/claim_success.png)

8. You can see the balance in the MetaMask extension.

   ![Balance](./assets/check_balance.png)

Note : If you are not able to see the funds in your wallet then make sure you're on the correct network and try to perform the steps again.

### Tips and Safety
- Back up your SRP offline; never share it or enter it into untrusted sites.
- Use MetaMask only from the official Chrome Web Store link above.
- Keep MetaMask and your browser up to date.
- Test networks use valueless ETH strictly for development and testing.

You’re all set to use MetaMask on Arbitrum Sepolia with test ETH.

---

## 5) Get your public address and private key

For EVM networks (Ethereum, Arbitrum, Base, and similar), dapps and faucets almost always ask for your **public address**—the hex string starting with `0x`. MetaMask shows that address rather than a separate “public key” field; paste the address when a site asks for your wallet address or public key.

**Never share your private key** (or Secret Recovery Phrase) with anyone or any website you do not fully trust. Anyone with a private key controls that account on that chain.

### Copy your public address from the home screen

1. Open MetaMask. Under your account name at the top, **hover** over the row of small network icons (and the copy control) directly below it. The addresses appear so you can see which chain is which before you copy.

   ![Hover over icons to see addresses](./assets/hover-over-icons-new.png)

2. On the main view, your account lists supported networks and shortened addresses.

   ![Addresses on the home screen](./assets/addresses.png)

3. Click the **copy** icon next to the network you need (for example **Ethereum** for most EVM testnets). MetaMask confirms when the full address is on your clipboard.

   ![Address copied confirmation](./assets/click-to-copy-new.png)

Use **View all** on that screen if you need additional networks.

### Export a private key for a specific chain (advanced)

Use this only when a trusted tool or workflow explicitly requires a raw private key (for example some local or development setups). Prefer connecting with MetaMask instead of pasting keys when possible.

1. Click your **account name** at the top (for example **Account 1**) to open the accounts list.

   ![Open account selector](./assets/click-on-account-1-new.png)

2. Click the **⋮** (three dots) on the right of the account you want.

   ![Open account menu](./assets/click-on-3-dots-new.png)

3. Choose **Account details**. On the Account screen, open **Private keys**.

   ![Choose Account details](./assets/click-on-account-details.png)

   ![Open Private keys](./assets/click-on-private-keys.png)

4. When MetaMask shows **Enter your password**, type your wallet password and tap **Confirm**. Enter your password only in the MetaMask extension window.

   ![Enter your password](./assets/enter-your-password.png)

5. On the private keys screen, read the warning, then click the **copy** icon next to the network whose key you need (for example **Ethereum**). Store the value securely and do not share it.

   ![Copy private key for a network](./assets/click-ethereum-to-copy-prvkey-new.png)

---

## 6) Troubleshooting: Increase Gas Fees (Arbitrum Sepolia Congestion)

Sometimes there might be network congestion on Arbitrum Sepolia. If your transaction fails or stays pending, you may need to increase gas fees so your transaction can go through. Follow the steps below.

1. First click on the Claim NFT Certification button after completing all of the chapters of the module. Only then you will be able to click on this button.

   ![Click Claim NFT Certification](./assets/image%20(22).png)

2. Once you have clicked on that button, a MetaMask pop up will appear. Click on the open-in-new (open) icon as shown in the screenshot.

   ![Click open icon](./assets/image%20(23).png)

3. Then click on the second option which is Advanced.

   ![Click Advanced](./assets/image%20(24).png)

4. Then simply remove the first 0 after the dot to make the amount near 0.2 in both Max base fee and Priority fee options, and then click on the Save button.

   ![Increase fees and Save](./assets/image%20(25).png)

5. Then click on the Confirm button and your transaction will go through.

   ![Confirm transaction](./assets/image%20(26).png)

Repeat the above steps and try to increase the gas more if your transaction still gets failed.

