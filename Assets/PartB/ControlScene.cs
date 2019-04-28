using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ControlScene : MonoBehaviour
{
    public Material B, C;
    
    // Start is called before the first frame update
    void Start()
    {
        C.SetFloat("_Steps", 0);
        B.SetFloat("_LookUpDistance",   0);
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKey(KeyCode.W))
        {
            Increase();
        }
        if (Input.GetKey(KeyCode.S))
        {
            Decrease();
        }
    }

    int blurIndex;
    int stepValue = 3;
    private void Increase()
    {
        blurIndex += stepValue; 
        C.SetFloat("_Steps", blurIndex);
        B.SetFloat("_LookUpDistance",   blurIndex / 3);
    }
    private void Decrease()
    {
        blurIndex -= stepValue;
        C.SetFloat("_Steps", blurIndex);
        B.SetFloat("_LookUpDistance", blurIndex / 3);
    }
}
