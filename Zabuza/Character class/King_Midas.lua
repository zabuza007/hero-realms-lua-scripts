require 'herorealms'
require 'decks'
require 'stdlib'
require 'timeoutai'
require 'hardai_2'
require 'aggressiveai'

function setupGame(g)
	registerCards(g, {
		midas_kings_advicer_carddef(),
		greed_is_good_skilldef(),
		golden_touch_abilitydef(),
		midas_liquid_gold_carddef(),
		midas_gold_carddef(),
	})
	
    standardSetup(g, {
        description = "You have the Midas touch. Everything you touch turns to gold",
        playerOrder = { plid1, plid2 },
        ai = ai.CreateKillSwitchAi(createAggressiveAI(),  createHardAi2()),
        timeoutAi = createTimeoutAi(),
        opponents = { { plid1, plid2 } },
        players = {
            {
                id = plid1,
                startDraw = 3,
                name = "King Midas",
                avatar="profit",
                health = 40,
                cards = {
					deck = {
						{ qty=4, card=midas_kings_advicer_carddef() },
                        { qty=4, card=midas_gold_carddef() },
                        { qty=2, card=midas_liquid_gold_carddef() },
                        -- { qty=2, card=rally_the_troops_carddef() },
						
					},
					skills = {
						{ qty=1, card=greed_is_good_skilldef() },
						{ qty=1, card=golden_touch_abilitydef() }
					},
					buffs = {
						drawCardsCountAtTurnEndDef(5),
						discardCardsAtTurnStartDef(),
						fatigueCount(40, 1, "FatigueP1")
					}
                }
            },
			{
                id = plid2,
                startDraw = 5,
				init = {
                    fromEnv = plid2
                },
                cards = {
					buffs = {
						drawCardsCountAtTurnEndDef(5),
						discardCardsAtTurnStartDef(),
						fatigueCount(40, 1, "FatigueP2")
					}
                }
            }           
        }
    })
end

function midas_kings_advicer_carddef()
	return createChampionDef({
        id="midas_kings_advicer",
        name="Kings advicer",
        types={championType, priestType},
        acquireCost=1,
        health = 1,
        isGuard = false,
        abilities = {
			createAbility({
				id = "kingsAdvicerMain",
				trigger = autoTrigger,
				effect = gainGoldEffect(1),
				cost = expendCost,
				activations = multipleActivations
			})
		},
        layout = createLayout({
			name = "Kings advicer",
			art = "art/T_Tithe_Priest",
			frame = "frames/Treasure_CardFrame",
			text = "<i>Lean into the power of “No” to fend off the distractions of shiny new objects.</i>",
			xmlText = [[<vlayout forceheight="false" spacing="6">
    <hlayout spacing="10">
       <icon text="{expend}" fontsize="50"/>
<icon text="{gold_1}" fontsize="50"/>
    </hlayout>    
    <divider/>
    <hlayout forcewidth="true" spacing="10">
        <vlayout  forceheight="false">
<text text="Lean into the power of 'No' to fend off the distractions of shiny new objects." fontsize="16"/>
        </vlayout>
    </hlayout>
</vlayout>]],
			health = 2,
			isGuard = false
        })
    })
end


function midas_gold_carddef()
	return createItemDef({
        id = "midas_gold",
        name = "Gold",
        types = { itemType, currencyType, coinType },
        acquireCost = 0,
        abilities = {
            createAbility({
                id = "midasGoldMain",
                effect = gainGoldEffect(1),
                cost = noCost,
                trigger = autoTrigger
            })
        },
        layout = createLayout({
			name = "Gold",
			art = "art/gold_male_pale",
			frame = "frames/Treasure_CardFrame",
			xmlText = [[<vlayout forceheight="false" spacing="6">
    <hlayout spacing="10">

<icon text="{gold_1}" fontsize="50"/>

</hlayout>
    <divider/>
    <hlayout forcewidth="true" spacing="10">
        <vlayout  forceheight="false">
<text text="Gold is forever. It is beautiful, useful, and never wears out." fontsize="16"/>
        </vlayout>
    </hlayout>
</vlayout>]],
        })
    })
end

function midas_liquid_gold_carddef()
	return createItemDef({
        id = "midas_liquid_gold",
        name = "Liquid gold",
        types = { itemType, currencyType, coinType },
        acquireCost = 0,
        abilities = {
            createAbility({
                id = "midasLiquidGoldMain",
                effect = gainGoldEffect(2),
                cost = noCost,
                trigger = autoTrigger
            })
        },
        layout = createLayout({
			name = "Liquid gold",
			art = "art/treasures/T_Cleric_Elixir_Golden",
			frame = "frames/Treasure_CardFrame",
			xmlText = [[<vlayout forceheight="false" spacing="6">
    <hlayout spacing="10">

<icon text="{gold_2}" fontsize="50"/>

</hlayout>
    <divider/>
    <hlayout forcewidth="true" spacing="10">
        <vlayout  forceheight="false">
<text text="Wine has never tasted better." fontsize="16"/>
        </vlayout>
    </hlayout>
</vlayout>]],
        })
    })
end



function greed_is_good_skilldef()
	return createSkillDef({
		id = "greed_is_good",
		name = "Greed is Good",
		cardTypeLabel = "Skill",
		types = { skillType },
        abilities = {
			createAbility({
				id = "GreedIsGoodActivate",
				trigger = uiTrigger,
				promptType = showPrompt,
				layout = createLayout({
					name = "Greed is good",
					art = "art/T_Bribe",
					frame = "frames/Treasure_CardFrame",
					text = "",
					xmlText = [[<vlayout forceheight="false" spacing="6">
									<hlayout spacing="5">
									   <icon text="{expend}" fontsize="75"/>
									   <text text="Lose 1 max Health to convert all gold you have in play into damage." fontsize="18"/>
									</hlayout> 
									<divider/>
									<hlayout forcewidth="true" spacing="10">
										<vlayout  forceheight="false">
											 <text text="Where Gold speaks, every tongue is silent." fontsize="14"/>
										</vlayout>
									</hlayout>
								</vlayout>]]
				}),
				effect = gainCombatEffect(getPlayerGold(currentPid)).seq(gainGoldEffect(getPlayerGold(currentPid).multiply(-1))).seq(gainHealthEffect(-1)).seq(gainMaxHealthEffect(currentPid, -1)) ,
				cost = expendCost
			})
		},
		layout = createLayout({
			name = "Greed is good",
			art = "art/T_Bribe",
			frame = "frames/Treasure_CardFrame",
			text = "",
			xmlText = [[<vlayout forceheight="false" spacing="6">
							<hlayout spacing="5">
							   <icon text="{expend}" fontsize="75"/>
							   <text text="Lose 1 max Health to convert all gold you have in play into damage." fontsize="18"/>
							</hlayout> 
							<divider/>
							<hlayout forcewidth="true" spacing="10">
								<vlayout  forceheight="false">
									 <text text="Where Gold speaks, every tongue is silent." fontsize="14"/>
								</vlayout>
							</hlayout>
						</vlayout>]]
		}),
		layoutPath= "art/T_Bribe"
	})
end	


function golden_touch_abilitydef()
	return createDef({
		id = "golden_touch",
		name = "Golden touch",
		acquireCost = 0,
		cardTypeLabel = "Ability",
		playLocation = skillsPloc,
		types = { heroAbilityType },
        abilities = {
			createAbility({
				id = "goldenTouchActivate",
				trigger = uiTrigger,
				promptType = showPrompt,
				layout = createLayout({
					name = "Golden touch",
					art = "art/T_Strength_In_Numbers",
					frame = "frames/Treasure_CardFrame",
					text = "",
					xmlText = [[
						<vlayout forceheight="false" spacing="6">
							<hlayout spacing="5">
								<icon text="{scrap}" fontsize="65"/>
								<text text="Sacrifice all champions you have in play and convert them back into gold." fontsize="20"/>
							</hlayout> 
						</vlayout>
					]]
				}),
				effect = gainGoldEffect(selectCurrentChampions().sum(getCardCost())).seq(sacrificeTarget().apply(selectCurrentChampions())),
				-- effect = sacrificeTarget().apply(selectCurrentChampions()),
				-- effect = sacrificeTarget().apply(selectLoc(loc(currentPid, inPlayPloc)).where(isCardChampion())),
				cost = sacrificeSelfCost
			})
		},
		layout = createLayout({
			name = "Golden touch",
			art = "art/T_Strength_In_Numbers",
			frame = "frames/Treasure_CardFrame",
			text = "",
			xmlText = [[
				<vlayout forceheight="false" spacing="6">
					<hlayout spacing="5">
						<icon text="{scrap}" fontsize="65"/>
						<text text="Sacrifice all champions you have in play and convert them back into gold." fontsize="20"/>
					</hlayout> 
				</vlayout>
			]]
		}),
		layoutPath= "art/T_Strength_In_Numbers"
	})
end	


function endGame(g)
end




function setupMeta(meta)
    meta.name = "King_Midas"
    meta.minLevel = 0
    meta.maxLevel = 0
    meta.introbackground = ""
    meta.introheader = ""
    meta.introdescription = ""
    meta.path = "X:/Mit drev/Realms Rising/LUA/King_Midas.lua"
     meta.features = {
}

end