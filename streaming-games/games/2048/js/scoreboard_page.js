var localStoreManager = new LocalStorageManager;


window.requestAnimationFrame(function () {
    localStoreManager.setGameName("2048");
    fillScoreboardPage(localStoreManager);
    loadScoreboard(localStoreManager);

    setUpScoreboardDeamonLoader(localStoreManager, 2000, true)

});
