require 'herorealms'
require 'decks'
require 'stdlib'
require 'timeoutai'
require 'hardai_2'
require 'aggressiveai'


local function chooseTheClass()
    return cardChoiceSelectorEffect({
        id = "choose_the_class_king_midas",
        name = "Choose a class",
        trigger = startOfTurnTrigger,

        upperTitle  = "Choose a class",
        lowerTitle  = "",

        effectFirst = sacrificeTarget().apply(selectLoc(loc(currentPid, handPloc)).union(selectLoc(loc(currentPid, deckPloc))).union(selectLoc(loc(currentPid, skillsPloc))))
			.seq(setPlayerNameEffect("King Midas", currentPid))
			.seq(setPlayerAvatarEffect("profit", currentPid))
			.seq(gainMaxHealthEffect(currentPid, const(42).add(getPlayerMaxHealth(currentPid).negate())))
			.seq(gainHealthEffect(42))
			.seq(createCardEffect(greed_is_good_skilldef(), currentSkillsLoc))
			.seq(createCardEffect(golden_touch_abilitydef(), currentSkillsLoc))
			.seq(createCardEffect(midas_kings_advicer_carddef(), currentDeckLoc))
			.seq(createCardEffect(midas_kings_advicer_carddef(), currentDeckLoc))
			.seq(createCardEffect(midas_kings_advicer_carddef(), currentDeckLoc))
			.seq(createCardEffect(midas_kings_advicer_carddef(), currentDeckLoc))
			.seq(createCardEffect(midas_gold_carddef(), currentDeckLoc))
			.seq(createCardEffect(midas_gold_carddef(), currentDeckLoc))
			.seq(createCardEffect(midas_gold_carddef(), currentDeckLoc))
			.seq(createCardEffect(midas_gold_carddef(), currentDeckLoc))
			.seq(createCardEffect(midas_liquid_gold_carddef(), currentDeckLoc))
			.seq(createCardEffect(midas_liquid_gold_carddef(), currentDeckLoc))
			.seq(shuffleEffect(currentDeckLoc))
			.seq(waitForClickEffect("Thank you for choosing your class.", ""))
		.seq(waitForClickEffect("If you enjoy this game, be sure to Favourite the script.", ""))
		.seq(waitForClickEffect("Once the game ends, click back on the game record tile. An 'Add to Favourites' tile will have appeared alongside 'Replay' and 'Rematch'.", ""))
		.seq(waitForClickEffect("Once favourited, you will be able to host your own custom games using this script.", ""))
		.seq(waitForClickEffect("For game to begin normally please end turn now. And remeber to check out Realmrising.com for more content", "")),
        effectSecond = waitForClickEffect("Thank you for choosing your class.", "")
		.seq(waitForClickEffect("If you enjoy this game, be sure to Favourite the script.", ""))
		.seq(waitForClickEffect("Once the game ends, click back on the game record tile. An 'Add to Favourites' tile will have appeared alongside 'Replay' and 'Rematch'.", ""))
		.seq(waitForClickEffect("Once favourited, you will be able to host your own custom games using this script.", ""))
		.seq(waitForClickEffect("For game to begin normally please end turn now. And remeber to check out Realmrising.com for more content", "")),

        layoutFirst = createLayout({
            name = "King Midas",
            art = "art/T_Bribe",
            frame = "frames/Treasure_CardFrame",
            text = "Play as a level 3 King Midas."  }),

        layoutSecond = createLayout({
            name = "Selected class",
            art = "art/T_All_Heroes",
            text = "Play as the character you selected when setting up the game." }),

        turn = 1
    })
end

local function goFirstEffect()
	return createGlobalBuff({
        id="draw_three_start_buff",
        name = "Go First",
        abilities = {
            createAbility({
                id="go_first_draw_effect",
                trigger = endOfTurnTrigger,
                effect = ifElseEffect(
					getTurnsPlayed(oppPid).eq(1),
					nullEffect(),
					drawCardsEffect(2)
				)
            })
        }
    })
end


function setupGame(g)
	registerCards(g, {
		werewolf_self_defence_human_carddef(),
		werewolf_self_defence_wolf_carddef(),
		werewolf_companion_human_carddef(),
		werewolf_companion_wolf_carddef(),
		werewolf_silver_flask_human_carddef(),
		werewolf_silver_flask_wolf_carddef(),
		werewolf_full_moon_carddef(),
		scry_werewolf_abillities(),
		inner_beast_skilldef(),
		call_too_the_moon_abilitydef(),
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
                startDraw = 10,
                name = "King Midas",
                avatar="profit",
                health = 50,
                cards = {
					deck = {
						{ qty=1, card=werewolf_full_moon_carddef() },
						{ qty=1, card=werewolf_silver_flask_human_carddef() },
                        { qty=2, card=werewolf_self_defence_human_carddef() },
                        { qty=2, card=werewolf_companion_human_carddef() },
						{ qty=4, card=gold_carddef() },
                        -- { qty=2, card=rally_the_troops_carddef() },
						
					},
					skills = {
						{ qty=1, card=inner_beast_skilldef() },
						{ qty=1, card=call_too_the_moon_abilitydef() },
						{ qty=1, card=scry_werewolf_abillities() }
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

function werewolf_full_moon_carddef()
	return createChampionDef({
        id="werewolf_full_moon",
        name="Full moon",
        types={championType, curseType},
        acquireCost=0,
        health = 4,
        isGuard = false,
        abilities = {
			createAbility({
				id = "fullMonnMain",
				trigger = autoTrigger,
				effect =  	waitForClickEffect("As the moon rises you feel the strengh running through you, as you transform to your wolfform.", "")

							-- transform self defence cards
							.seq(transformTarget("werewolf_self_defence_wolf").apply(	selectLoc(loc(currentPid, handPloc))
																						.union(selectLoc(loc(currentPid, inPlayPloc)))
																						.union(selectLoc(loc(currentPid, discardPloc)))
																						.union(selectLoc(loc(currentPid, deckPloc)))
																						.where(isCardName("werewolf_self_defence_human"))
																					))
							.seq(gainCombatEffect(selectLoc(loc(currentPid, castPloc)).where(isCardName("werewolf_self_defence_human")).count().multiply(-2))) -- negate the dmg from played werewolf_self_defence_human 
							.seq(transformTarget("werewolf_self_defence_wolf").apply(selectLoc(loc(currentPid, castPloc)).where(isCardName("werewolf_self_defence_human"))))

							-- transform wolf companion
							.seq(transformTarget("werewolf_companion_wolf").apply(	selectLoc(loc(currentPid, handPloc))
																					.union(selectLoc(loc(currentPid, inPlayPloc)))
																					.union(selectLoc(loc(currentPid, discardPloc)))
																					.union(selectLoc(loc(currentPid, deckPloc)))
																					.where(isCardName("werewolf_companion_human"))
																				))
							--.seq(gainHealthEffect(selectLoc(loc(currentPid, castPloc)).where(isCardName("werewolf_companion_human")).count().multiply(-2))) -- negate the heal from played werewolf_companion_human 
							.seq(transformTarget("werewolf_companion_wolf").apply(selectLoc(loc(currentPid, castPloc)).where(isCardName("werewolf_companion_human"))))
							.seq(transformTarget("werewolf_silver_flask_wolf").apply( 	selectLoc(loc(currentPid, handPloc))
																						.union(selectLoc(loc(currentPid, inPlayPloc)))
																						.union(selectLoc(loc(currentPid, discardPloc)))
																						.union(selectLoc(loc(currentPid, deckPloc)))
																						.union(selectLoc(loc(currentPid, castPloc)))
																						.where(isCardName("werewolf_silver_flask_human"))
																				)
							),
							
				activations = singleActivation
			}),
			createAbility({
				id = "fullMonnLeave",
				trigger = onLeavePlayTrigger,
				effect =  	waitForClickEffect("As the moon leaves the sky you see the strengh draining from your opponent, as they return to human form.", "")
							-- transform self defence cards
							.seq(transformTarget("werewolf_self_defence_human").apply( 	selectLoc(loc(currentPid, handPloc))
																						.union(selectLoc(loc(currentPid, inPlayPloc)))
																						.union(selectLoc(loc(currentPid, discardPloc)))
																						.union(selectLoc(loc(currentPid, deckPloc)))
																						.union(selectLoc(loc(currentPid, castPloc)))
																						.union(selectLoc(loc(oppPid, handPloc)))
																						.union(selectLoc(loc(oppPid, inPlayPloc)))
																						.union(selectLoc(loc(oppPid, discardPloc)))
																						.union(selectLoc(loc(oppPid, deckPloc)))
																						.union(selectLoc(loc(oppPid, castPloc)))
																						.where(isCardName("werewolf_self_defence_wolf"))
																				))
							-- transform wolf companion
							.seq(transformTarget("werewolf_companion_human").apply( 	selectLoc(loc(currentPid, handPloc))
																						.union(selectLoc(loc(currentPid, inPlayPloc)))
																						.union(selectLoc(loc(currentPid, discardPloc)))
																						.union(selectLoc(loc(currentPid, deckPloc)))
																						.union(selectLoc(loc(currentPid, castPloc)))
																						.union(selectLoc(loc(oppPid, handPloc)))
																						.union(selectLoc(loc(oppPid, inPlayPloc)))
																						.union(selectLoc(loc(oppPid, discardPloc)))
																						.union(selectLoc(loc(oppPid, deckPloc)))
																						.union(selectLoc(loc(oppPid, castPloc)))
																						.where(isCardName("werewolf_companion_wolf"))
																				))
							-- transform silver flask
							.seq(transformTarget("werewolf_silver_flask_human").apply( 	selectLoc(loc(currentPid, handPloc))
																						.union(selectLoc(loc(currentPid, inPlayPloc)))
																						.union(selectLoc(loc(currentPid, discardPloc)))
																						.union(selectLoc(loc(currentPid, deckPloc)))
																						.union(selectLoc(loc(currentPid, castPloc)))
																						.union(selectLoc(loc(oppPid, handPloc)))
																						.union(selectLoc(loc(oppPid, inPlayPloc)))
																						.union(selectLoc(loc(oppPid, discardPloc)))
																						.union(selectLoc(loc(oppPid, deckPloc)))
																						.union(selectLoc(loc(oppPid, castPloc)))
																						.where(isCardName("werewolf_silver_flask_wolf"))
																				)
							),
				activations = singleActivation,
			})
		},
		-- onLeavePlayTrigger
        layout = createLayout({
			name = "Full moon",
			art = "art/T_Wind_Storm",
			frame = "frames/HR_CardFrame_Champion_Wild",
			text = "",
			xmlText = [[<vlayout forceheight="false" spacing="6">
    <hlayout  spacing="10">
        <vlayout  forceheight="true">
<text text="A full moon night, awakens the inner beast from its slumber!" fontstyle="italic" fontsize="20"/>
        </vlayout>
    </hlayout>
</vlayout>]],
        })
    })
end


function werewolf_silver_flask_human_carddef()
	return createItemDef({
        id="werewolf_silver_flask_human",
        name="Silver flask",
        types={itemType},
        acquireCost=0,
        abilities = {
			createAbility({
				id = "werewolf_silver_flask_human_action",
				trigger = autoTrigger,
				effect = gainGoldEffect(1).seq(gainHealthEffect(1)),
                cost = noCost,
				activations = singleActivation
			}),
			createAbility({
				id = "werewolf_silver_flask_human_sacrifice",
				trigger = uiTrigger,
				promptType = showPrompt,
				effect = gainGoldEffect(2),
                cost = sacrificeSelfCost,
				activations = singleActivation,
				layout = createLayout({
					name = "Silver flask",
					art = "art/treasures/T_Thief_Elixir_White",
					frame = "frames/Generic_CardFrame",
					text = "",
					xmlText = [[
						<vlayout forceheight="false" spacing="6">
							<hlayout spacing="10">

						<icon text="{gold_1}" fontsize="40"/>

						<icon text="{health_1}" fontsize="40"/>
						</hlayout>
							<divider/>
						<hlayout spacing="10">
								<icon text="{scrap}" fontsize="40"/>
								<vlayout  forceheight="true">
						<text text="Sell you silver flask for some extra coin {gold_2}" fontsize="18"/>
								</vlayout>
							</hlayout><divider/>
							<hlayout forcewidth="true" spacing="10">
								<vlayout  forceheight="false">
						<text text="Sometimes friends can be found a the bottom." fontstyle="italic" fontsize="14"/>
								</vlayout>
							</hlayout>
						</vlayout>
					]]
				})
			}),
		},
        layout = createLayout({
			name = "Silver flask",
			art = "art/treasures/T_Thief_Elixir_White",
			frame = "frames/Generic_CardFrame",
			text = "",
			xmlText = [[<vlayout forceheight="false" spacing="6">
    <hlayout spacing="10">

<icon text="{gold_1}" fontsize="40"/>

<icon text="{health_1}" fontsize="40"/>
</hlayout>
    <divider/>
<hlayout spacing="10">
        <icon text="{scrap}" fontsize="40"/>
        <vlayout  forceheight="true">
<text text="Sell you silver flask for some extra coin {gold_2}" fontsize="18"/>
        </vlayout>
    </hlayout><divider/>
    <hlayout forcewidth="true" spacing="10">
        <vlayout  forceheight="false">
<text text="Sometimes friends can be found a the bottom." fontstyle="italic" fontsize="14"/>
        </vlayout>
    </hlayout>
</vlayout>]],
        })
    })
end

function werewolf_silver_flask_wolf_carddef()
	return createItemDef({
        id="werewolf_silver_flask_wolf",
        name="Silver flask",
        types={itemType},
        acquireCost=0,
        abilities = {
			createAbility({
				id = "werewolf_silver_flask_wolf_sacrifice",
				trigger = uiTrigger,
				promptType = showPrompt,
				effect = gainCombatEffect(math.random(5)),
                cost = sacrificeSelfCost,
				activations = singleActivation,
				layout = createLayout({
					name = "Silver flask",
					art = "art/treasures/T_Thief_Elixir_White",
					frame = "frames/Generic_CardFrame",
					text = "",
					xmlText = [[
						<vlayout forceheight="false" spacing="6">
							<hlayout spacing="10">
								<text text="Drinking won't help in this form." fontstyle="italic" fontsize="14"/>
							</hlayout>
							<divider/>
							<hlayout spacing="10">
								<icon text="{scrap}" fontsize="40"/>
								<vlayout  forceheight="true">
									<text text="You could throw it to deal some damage, but you won't get it back." fontstyle="italic" fontsize="16"/>
									<text text="{combat_1} - {combat_5}" fontsize="40"/>
								</vlayout>
							</hlayout>
						</vlayout>
					]]
				})
			}),
		},
        layout = createLayout({
			name = "Silver flask",
			art = "art/treasures/T_Thief_Elixir_White",
			frame = "frames/Generic_CardFrame",
			text = "",
			xmlText = [[<vlayout forceheight="false" spacing="6">
							<hlayout spacing="10">
								<text text="Drinking won't help in this form." fontstyle="italic" fontsize="14"/>
							</hlayout>
							<divider/>
							<hlayout spacing="10">
								<icon text="{scrap}" fontsize="40"/>
								<vlayout  forceheight="true">
									<text text="You could throw it to deal some damage, but you won't get it back." fontstyle="italic" fontsize="16"/>
									<text text="{combat_1} - {combat_5}" fontsize="40"/>
								</vlayout>
							</hlayout>
						</vlayout>]],
        })
    })
end


function werewolf_knifebelt_wolf_carddef()
	return createItemDef({
        id="werewolf_knifebelt_wolf",
        name="Self defence - Scythe",
        types={itemType, meleeWeaponType},
        acquireCost=0,
        abilities = {
			createAbility({
				id = "selfDefenceHuman",
				trigger = autoTrigger,
				effect = gainCombatEffect(2),
                cost = noCost,
				activations = singleActivation
			})
		},
        layout = createLayout({
			name = "Self defence - Scythe",
			art = "art/T_Fighter_Hand_Scythe",
			frame = "frames/Generic_CardFrame",
			text = "",
			xmlText = [[<vlayout forceheight="false" spacing="6">
    <hlayout spacing="10">

<icon text="{combat_2}" fontsize="50"/>

</hlayout>
    <divider/>
    <hlayout forcewidth="true" spacing="10">
        <vlayout  forceheight="false">
<text text="Sometimes you need to defend yourself." fontstyle="italic" fontsize="16"/>
        </vlayout>
    </hlayout>
</vlayout>]],
        })
    })
end


function werewolf_self_defence_human_carddef()
	return createItemDef({
        id="werewolf_self_defence_human",
        name="Self defence - Scythe",
        types={itemType, meleeWeaponType},
        acquireCost=0,
        abilities = {
			createAbility({
				id = "selfDefenceHuman",
				trigger = autoTrigger,
				effect = gainCombatEffect(2),
                cost = noCost,
				activations = singleActivation
			})
		},
        layout = createLayout({
			name = "Self defence - Scythe",
			art = "art/T_Fighter_Hand_Scythe",
			frame = "frames/Generic_CardFrame",
			text = "",
			xmlText = [[<vlayout forceheight="false" spacing="6">
    <hlayout spacing="10">

<icon text="{combat_2}" fontsize="50"/>

</hlayout>
    <divider/>
    <hlayout forcewidth="true" spacing="10">
        <vlayout  forceheight="false">
<text text="Sometimes you need to defend yourself." fontstyle="italic" fontsize="16"/>
        </vlayout>
    </hlayout>
</vlayout>]],
        })
    })
end


function werewolf_self_defence_wolf_carddef()
	return createActionDef({
        id="werewolf_self_defence_wolf",
        name="Wolf Frenzy",
        types={actionType, meleeWeaponType},
        acquireCost=0,
        abilities = {
			createAbility({
				id = "selfDefenceWolf",
				trigger = autoTrigger,
				effect = gainCombatEffect(5),
                cost = noCost,
				activations = singleActivation
			})
		},
        layout = createLayout({
			name = "Wolf Frenzy",
			art = "art/T_Wolf_Form",
			frame = "frames/HR_CardFrame_Action_Wild",
			text = "",
			xmlText = [[<vlayout forceheight="false" spacing="6">
    <hlayout spacing="10">

<icon text="{combat_5}" fontsize="50"/>

</hlayout>
    <divider/>
    <hlayout forcewidth="true" spacing="10">
        <vlayout  forceheight="false">
<text text="Now it's their turn to defend themself." fontstyle="italic" fontsize="16"/>
        </vlayout>
    </hlayout>
</vlayout>]],
        })
    })
end


function werewolf_companion_human_carddef()
	return createChampionDef({
        id="werewolf_companion_human",
        name="Comfort of the pack",
        types={championType, wolfType},
        acquireCost=0,
        health = 1,
        isGuard = false,
        abilities = {
			createAbility({
				id = "werewolfCompanionHumanMain",
				trigger = autoTrigger,
				effect = gainHealthEffect(2),
				cost = expendCost,
				activations = multipleActivations
			})
		},
        layout = createLayout({
			name = "Comfort of the pack",
			art = "art/T_Cunning_Of_The_Wolf",
			frame = "frames/HR_CardFrame_Champion_Wild",
			text = "",
			xmlText = [[<vlayout forceheight="false" spacing="6">
    <hlayout spacing="10">

<icon text="{health_2}" fontsize="50"/>

</hlayout>
    <divider/>
    <hlayout forcewidth="true" spacing="10">
        <vlayout  forceheight="false">
<text text="When you need a place to rest you can always go to the pack." fontstyle="italic" fontsize="16"/>
        </vlayout>
    </hlayout>
</vlayout>]],
        })
    })
end


function werewolf_companion_wolf_carddef()
	return createChampionDef({
        id="werewolf_companion_wolf",
        name="Strengh in numbers",
        types={championType, wolfType},
        acquireCost=0,
        health = 2,
        isGuard = true,
        abilities = {
			createAbility({
				id = "werewolfCompanionwolfMain",
				trigger = autoTrigger,
				effect = gainCombatEffect(2),
				cost = expendCost,
				activations = multipleActivations
			})
		},
        layout = createLayout({
			name = "Strengh in numbers",
			art = "art/T_Strength_Of_The_Wolf",
			frame = "frames/HR_CardFrame_Champion_Wild",
			text = "",
			xmlText = [[<vlayout forceheight="false" spacing="6">
    <hlayout spacing="10">

<icon text="{combat_2}" fontsize="50"/>

</hlayout>
    <divider/>
    <hlayout forcewidth="true" spacing="10">
        <vlayout  forceheight="false">
<text text="When you attack one, you attack them all." fontstyle="italic" fontsize="16"/>
        </vlayout>
    </hlayout>
</vlayout>]],
        })
    })
end


function inner_beast_skilldef()
	return createSkillDef({
		id = "inner_beast",
		name = "Inner beast",
		cardTypeLabel = "Skill",
		types = { skillType },
        abilities = {
			createAbility({
				id = "innerBeastActive",
				trigger = uiTrigger,
				promptType = showPrompt,
				layout = createLayout({
					name = "Inner beast",
					art = "art/T_Dire_Wolf",
					frame = "frames/HR_CardFrame_Action_Wild",
					text = "",
					xmlText = [[<vlayout forceheight="false" spacing="6">
									<hlayout spacing="5">
									   <icon text="{expend_2}" fontsize="75"/>
									   <icon text="{combat_4}" fontsize="75"/>
									</hlayout> 
									<divider/>
									<hlayout forcewidth="true" spacing="10">
										<vlayout  forceheight="false">
											 <text text="They will regret hunting you." fontstyle="italic" fontsize="14"/>
										</vlayout>
									</hlayout>
								</vlayout>]]
				}),
				effect = gainCombatEffect(4) ,
				cost = expendCost
			})
		},
		layout = createLayout({
			name = "Inner beast",
			art = "art/T_Dire_Wolf",
			frame = "frames/HR_CardFrame_Action_Wild",
			text = "",
			xmlText = [[<vlayout forceheight="false" spacing="6">
							<hlayout spacing="5">
							   <icon text="{expend_2}" fontsize="75"/>
							   <icon text="{combat_4}" fontsize="75"/>
							</hlayout> 
							<divider/>
							<hlayout forcewidth="true" spacing="10">
								<vlayout  forceheight="false">
									 <text text="They will regret hunting you." fontstyle="italic" fontsize="14"/>
								</vlayout>
							</hlayout>
						</vlayout>]]
		}),
		layoutPath= "art/T_Dire_Wolf"
	})
end	


function call_too_the_moon_abilitydef()
	return createDef({
		id = "call_too_the_moon",
		name = "Summon the moon",
		acquireCost = 0,
		cardTypeLabel = "Ability",
		playLocation = skillsPloc,
		types = { heroAbilityType },
        abilities = {
			createAbility({
				id = "callToTheMoonActive",
				trigger = uiTrigger,
				promptType = showPrompt,
				layout = createLayout({
					name = "Summon the moon",
					art = "art/T_Wolf_Shaman",
					frame = "frames/HR_CardFrame_Champion_Wild",
					text = "",
					xmlText = [[
						<vlayout forceheight="false" spacing="6">
							<hlayout spacing="5">
								<icon text="{scrap}" fontsize="65"/>
								<text text="With the help of the Wolf Shamans it is posible to call forth the full moon - even during the day." fontstyle="italic" fontsize="18" />
							</hlayout> 
						</vlayout>
					]]
				}),
				effect = sacrificeTarget().apply(	selectLoc(loc(currentPid, handPloc))
													.union(selectLoc(loc(currentPid, deckPloc)))
													.union(selectLoc(loc(currentPid, inPlayPloc)))
													.union(selectLoc(loc(currentPid, discardPloc)))
													.union(selectLoc(loc(currentPid, castPloc)))
													.where(isCardName("werewolf_full_moon"))
												)
						.seq(createCardEffect(werewolf_full_moon_carddef(), currentHandLoc)),
				
				cost = sacrificeSelfCost
			})
		},
		layout = createLayout({
			name = "Call to the moon",
			art = "art/T_Wolf_Shaman",
			frame = "frames/HR_CardFrame_Champion_Wild",
			text = "",
			xmlText = [[
				<vlayout forceheight="false" spacing="6">
					<hlayout spacing="5">
						<icon text="{scrap}" fontsize="65"/>
						<text text="With the help of the Wolf Shamans it is posible to call forth the full moon - even during the day." fontstyle="italic" fontsize="18" />
					</hlayout> 
				</vlayout>
			]]
		}),
		layoutPath= "art/T_Wolf_Shaman"
	})
end	



function scry_werewolf_abillities()
	return createDef({
		id = "scry_werewolf_abillities",
		name = "When the full moon is out, the werewolfs deck changes.",
		acquireCost = 0,
		cardTypeLabel = "Ability",
		playLocation = skillsPloc,
		types = { heroAbilityType },
        abilities = {
			createAbility({
				id = "callToTheMoonActive",
				trigger = uiTrigger,
				promptType = showPrompt,
				layoutFirst = createLayout({
					name = "King Midas",
					art = "art/T_Bribe",
					frame = "frames/Treasure_CardFrame",
					text = "Play as a level 3 King Midas."  }),

				layoutSecond = createLayout({
					name = "Selected class",
					art = "art/T_All_Heroes",
					text = "Play as the character you selected when setting up the game." }),
				effect = nullEffect(),
				cost = noCost
			})
			
		},
		layoutPath= "art/T_Wolf_Shaman"
	})
end	


function endGame(g)
end





function setupMeta(meta)
    meta.name = "Werewolf"
    meta.minLevel = 0
    meta.maxLevel = 0
    meta.introbackground = ""
    meta.introheader = ""
    meta.introdescription = ""
    meta.path = "C:/Users/glatk/Documents/HR - LUA/hero-realms-lua-scripts/Zabuza/Character class/Werewolf.lua"
     meta.features = {
}

end