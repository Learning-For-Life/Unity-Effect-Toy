using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomBirth : MonoBehaviour
{
    public GameObject wolf1;

    public int x;
    public int y;

    private void Start()
    {
        birth();
    }

    public void birth()
    {
        for (x = 0; x < 300; x++)
        {
            for (y = 0; y < 300; y++)
            {
                GameObject obj = (GameObject)Instantiate(wolf1);
                obj.transform.position = new Vector3(x, 5, y);
            }
        }
    }
}